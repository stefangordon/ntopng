--
-- (C) 2013-22 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/pro/scripts/lua/enterprise/modules/?.lua;" .. package.path
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path
package.path = dirs.installdir .. "/scripts/lua/modules/toasts/?.lua;" .. package.path

if((dirs.scriptdir ~= nil) and (dirs.scriptdir ~= "")) then package.path = dirs.scriptdir .. "/lua/modules/?.lua;" .. package.path end
require "lua_utils"

local alerts_api = require("alerts_api")
local recording_utils = require "recording_utils"
local telemetry_utils = require "telemetry_utils"
local ts_utils = require("ts_utils_core")
local format_utils = require "format_utils"
local page_utils = require("page_utils")
local delete_data_utils = require "delete_data_utils"
local toasts_manager = require("toasts_manager")
local host_pools = require "host_pools"
local blog_utils = require("blog_utils")
local template_utils = require "template_utils"
local auth = require "auth"
local is_nedge = ntop.isnEdge()
local is_appliance = ntop.isAppliance()
local is_admin = isAdministrator()
local is_windows = ntop.isWindows()
local info = ntop.getInfo()
local has_local_auth = (ntop.getPref("ntopng.prefs.local.auth_enabled") ~= '0')
local is_system_interface = page_utils.is_system_view()
local behavior_utils = require("behavior_utils")
local checks = require "checks"
local session_user = _SESSION['user']

local observationPointId = nil

print([[
   <div class='wrapper'>
]])

print[[
<script type='text/javascript'>

   const isAdministrator = ]] print(is_admin) print[[;
   const loggedUser = "]] print(_SESSION['user']) print[[";
   const interfaceID = ]] print(interface.getStats().id) print[[;

   /* Some localization strings to pass from lua to javascript */
   const i18n_ext = {
      "no_results_found": "]] print(i18n("no_results_found")) print[[",
      "are_you_sure": "]] print(i18n("scripts_list.are_you_sure")) print[[",
      "change_number_of_rows": "]] print(i18n("change_number_of_rows")) print[[",
      "no_data_available": "]] print(i18n("no_data_available")) print[[",
      "showing_x_to_y_rows": "]] print(i18n("showing_x_to_y_rows", {x="{0}", y="{1}", tot="{2}"})) print[[",
      "actions": "]] print(i18n("actions")) print[[",
      "query_was_aborted": "]] print(i18n("graphs.query_was_aborted")) print[[",
      "exports": "]] print(i18n("system_stats.exports_label")) print[[",
      "no_file": "]] print(i18n("config_scripts.no_file")) print[[",
      "invalid_file": "]] print(i18n("config_scripts.invalid_file")) print[[",
      "request_failed_message": "]] print(i18n("request_failed_message")) print[[",
      "all": "]] print(i18n("all")) print[[",
      "edit": "]] print(i18n("edit")) print[[",
      "remove": "]] print(i18n("remove")) print[[",
      "and": "]] print(i18n("and")) print[[",
      "other": "]] print(i18n("other")) print[[",
      "others": "]] print(i18n("others")) print[[",
      "warning": "]] print(i18n("warning")) print[[",
      "search": "]] print(i18n("search")) print[[",
      "as": "]] print(i18n("as")) print[[",
      "no_recipients": "]] print(i18n("endpoint_notifications.no_recipients")) print[[",
      "score": "]] print(i18n("score")) print[[",
      "alerted_flows": "]] print(i18n("flow_details.alerted_flows")) print[[",
      "blacklisted_flows": "]] print(i18n("alerts_dashboard.blacklisted_flow")) print[[",
      "flow_status": "]] print(i18n("graphs.flow_status")) print[[",
      "traffic_rcvd": "]] print(i18n("graphs.traffic_rcvd")) print[[",
      "traffic_sent": "]] print(i18n("graphs.traffic_sent")) print[[",
      "flows": "]] print(i18n("db_explorer.total_flows")) print[[",
      "nation": "]] print(i18n("nation")) print[[",
      "and_x_more": "]] print(i18n("and_x_more", { num = '$num'})) print[[",
      "invalid_input": "]] print(i18n("validation.invalid_input")) print[[",
      "missing_field": "]] print(i18n("validation.missing_field")) print[[",
      "unreachable_host": "]] print(i18n("graphs.unreachable_host")) print[[",
      "NAME_RESOLUTION_FAILED": "]] print(i18n("rest_consts.NAME_RESOLUTION_FAILED")) print[[",
      "FAILED_HTTP_REQUEST": "]] print(i18n("validation.FAILED_HTTP_REQUEST")) print[[",
      "rest_consts": {
         "PARTIAL_IMPORT": "]] print(i18n("rest_consts.PARTIAL_IMPORT")) print[[",
         "CONFIGURATION_FILE_MISMATCH": "]] print(i18n("rest_consts.CONFIGURATION_FILE_MISMATCH")) print[[",
      }
   };
   const systemInterfaceEnabled = ]] print(ternary(is_system_interface, "true", "false")) print[[;
   const http_prefix = "]] print(ntop.getHttpPrefix()) print[[";

   window.unchangable_pool_names = [
      'Jailed Hosts'
   ]

   window.__CSRF_DATATABLE__ = `]] print(ntop.getRandomCSRFValue()) print[[`;
   window.__BLOG_NOTIFICATION_CSRF__ = `]] print(ntop.getRandomCSRFValue()) print[[`;

   if (document.cookie.indexOf("tzoffset=") < 0) {
      // Tell the server the client timezone
      document.cookie = "tzoffset=" + (new Date().getTimezoneOffset() * 60 * -1);
   }
</script>]]

prefs = ntop.getPrefs()
local iface_names = interface.getIfNames()

-- tprint(prefs)
-- tprint(iface_names)

num_ifaces = 0
for k,v in pairs(iface_names) do
   num_ifaces = num_ifaces+1
end


interface.select(ifname)
local ifs = interface.getStats()
local is_pcap_dump = interface.isPcapDumpInterface()
local is_packet_interface = interface.isPacketInterface()
local is_viewed = ifs.isViewed
local is_influxdb_enabled = false
ifId = ifs.id

-- NOTE: see sidebar.js for the client logic
page_utils.init_menubar()

if is_nedge then
   dofile(dirs.installdir .. "/pro/scripts/lua/nedge/inc/menubar.lua")
else
   -- ##############################################

   -- Shortcuts
   -- The Shortcuts entry are used to go to the System interface pages
   -- without using the Interface dropdown. The section is hidden
   -- in system interface.
   page_utils.add_menubar_section({
      section = page_utils.menu_sections.shortcuts,
      hidden = is_system_interface or not is_admin,
      entries = {
         {
            entry = page_utils.menu_entries.snmp,
            hidden = (not ntop.isEnterpriseM() and not ntop.isnEdgeEnterprise()),
            url = "/lua/pro/enterprise/snmpdevices_stats.lua"
         },
         {
            entry = page_utils.menu_entries.active_monitoring,
            url = "/lua/monitor/active_monitoring_monitor.lua"
         },         
         {
            entry = page_utils.menu_entries.divider,
            hidden = not ntop.isEnterpriseM(),
         },
         {
            entry = page_utils.menu_entries.manage_pools,
            hidden = not is_admin,
            url = '/lua/admin/manage_pools.lua'
         },
         {
            entry = page_utils.menu_entries.divider,
         },
         {
            entry = page_utils.menu_entries.endpoint_notifications,
            hidden = not is_admin,
            url = '/lua/admin/endpoint_notifications_list.lua',
         },
         {
            entry = page_utils.menu_entries.endpoint_recipients,
            hidden = not is_admin,
            url = '/lua/admin/recipients_list.lua',
         },
      }
   })
   
   -- Dashboard
   page_utils.add_menubar_section(
   {
      section = page_utils.menu_sections.dashboard,
      hidden = is_pcap_dump or is_system_interface,
      entries = 
      {
         {
	    entry = page_utils.menu_entries.traffic_dashboard,
	    url = ntop.isPro() and '/lua/pro/dashboard.lua' or '/lua/index.lua',
         },
	 {
	    entry = page_utils.menu_entries.traffic_analysis,
	    hidden = not ntop.isEnterprise() or 
                not prefs.is_dump_flows_to_clickhouse_enabled or 
                ifs.isViewed or not 
                (auth.has_capability(auth.capabilities.historical_flows) and not 
                  ntop.getPref("ntopng.user." .. session_user .. ".allow_historical_flow") == "1" and not 
                  is_admin),
	    url = "/lua/pro/db_search.lua?page=analysis",
	 },
         {
            entry = page_utils.menu_entries.divider,
         },
	 {
	    entry = page_utils.menu_entries.network_discovery,
	    hidden = not interface.isDiscoverableInterface() or interface.isLoopback(),
	    url = "/lua/discover.lua",
	 },
	 {
	    entry = page_utils.menu_entries.traffic_report,
	    hidden = not ntop.isPro(),
	    url = "/lua/pro/report.lua",
	 },
      },
   })

   -- ##############################################

   -- Alerts
   page_utils.add_menubar_section(
      {
	 section = page_utils.menu_sections.alerts,
	 hidden = not ntop.getPrefs().are_alerts_enabled or not auth.has_capability(auth.capabilities.alerts),
         url = '/lua/alert_stats.lua',
      }
   )

   -- ##############################################

   -- Flows
   page_utils.add_menubar_section({
      section = page_utils.menu_sections.flows,
      hidden = is_system_interface,
      entries = {
	 {
	    entry = page_utils.menu_entries.active_flows,
	    url = "/lua/flows_stats.lua",
	 },
	 {
	    entry = page_utils.menu_entries.db_explorer,
      hidden = not ntop.isEnterprise() or (not prefs.is_dump_flows_to_clickhouse_enabled) or ifs.isViewed or 
                not auth.has_capability(auth.capabilities.historical_flows) or 
                not (ntop.getPref("ntopng.user." .. session_user .. ".allow_historical_flow") == "1" or is_admin),
	    url = "/lua/pro/db_search.lua",
	 },
      }
   })

   -- ##############################################

   -- Hosts
   page_utils.add_menubar_section(
      {
	 section = page_utils.menu_sections.hosts,
	 hidden = is_system_interface or is_viewed,
	 entries = {
	    {
	       entry = page_utils.menu_entries.hosts,
	       url = '/lua/hosts_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.devices,
	       hidden = not ifs.has_macs,
	       url = '/lua/macs_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.networks,
	       url = '/lua/network_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.host_pools,
	       url = '/lua/pool_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.autonomous_systems,
	       hidden = not ntop.hasGeoIP(),
	       url = '/lua/as_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.countries,
	       hidden = not ntop.hasGeoIP(),
	       url = '/lua/country_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.operating_systems,
	       url = '/lua/os_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.vlans,
	       hidden = not interface.hasVLANs(),
	       url = '/lua/vlan_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.pods,
	       hidden = not ifs.has_seen_pods,
	       url = '/lua/pods_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.containers,
	       hidden = not ifs.has_seen_containers,
	       url = '/lua/containers_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.divider,
	    },
	    {
	       entry = page_utils.menu_entries.http_servers,
	       url = '/lua/http_servers_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.top_hosts,
	       hidden = is_pcap_dump,
	       url = '/lua/top_hosts.lua',
	    },
	 },
      }
   )

   -- ##############################################

   -- Exporters
   page_utils.add_menubar_section(
      {
	 section = page_utils.menu_sections.collection,
	 hidden = ((ifs.type ~= "zmq" and ifs.type ~= "custom") or not ntop.isEnterpriseM()) or is_system_interface,
	 entries = {
	    {
	       entry = page_utils.menu_entries.event_exporters,
	       hidden = not ifs.has_seen_ebpf_events,
	       url = '/lua/pro/enterprise/event_exporters.lua',
	    },
	    {
	       entry = page_utils.menu_entries.sflow_exporters,
	       hidden = table.len(interface.getSFlowDevices() or {}) == 0,
	       url = '/lua/pro/enterprise/sflowdevices_stats.lua',
	    },
	    {
	       entry = page_utils.menu_entries.exporters,
	       url = '/lua/pro/enterprise/flowdevices_stats.lua',
	    },
       {
          entry = page_utils.menu_entries.observation_points,
          hidden = table.len(interface.getObsPointsInfo() or {}) == 0,
          url = '/lua/pro/enterprise/observation_points.lua',
       },
	 },
      }
   )

end

-- ##############################################

-- Maps

local service_map_available = false
local periodicity_map_available = false

service_map_available, periodicity_map_available = behavior_utils.mapsAvailable()

page_utils.add_menubar_section({
  section = page_utils.menu_sections.maps,
  hidden = is_system_interface or is_viewed,
  entries = {
   {
      entry = page_utils.menu_entries.service_map,
      hidden = not service_map_available,
      url = '/lua/pro/enterprise/network_maps.lua?map=service_map',
   },
   {
      entry = page_utils.menu_entries.periodicity_map,
      hidden = not periodicity_map_available,
      url = '/lua/pro/enterprise/network_maps.lua?map=periodicity_map',
	 },
	 {
	    entry = page_utils.menu_entries.geo_map,
	    hidden = interface.isLoopback() or not ntop.hasGeoIP(),
	    url = '/lua/hosts_geomap.lua',
	 },
	 {
	    entry = page_utils.menu_entries.hosts_map,
	    url = '/lua/hosts_map.lua',
	 },
      }
})

-- ##############################################

-- Interface
page_utils.add_menubar_section(
   {
      section = page_utils.menu_sections.if_stats,
      hidden = is_system_interface,
      url = "/lua/if_stats.lua",
   }
)


-- ##############################################

-- System Health

local health_entries = {
      {
         entry = page_utils.menu_entries.system_status,
         url = '/lua/system_stats.lua',
      },
      {
         entry = page_utils.menu_entries.interfaces_status,
         url = '/lua/system_interfaces_stats.lua',
      },
      {
         entry = page_utils.menu_entries.alerts_status,
         url = '/lua/system_alerts_stats.lua',
      },
      {
         entry = page_utils.menu_entries.influxdb_status,
         url = '/lua/monitor/influxdb_monitor.lua',
         hidden = not is_influxdb_enabled,
      },
      {
         entry = page_utils.menu_entries.redis_status,
         url = '/lua/monitor/redis_monitor.lua',
         hidden = false, -- TODO: add a check for redis monitoring status
      },
      {
         entry = page_utils.menu_entries.clickhouse_status,
         url = '/lua/enterprise/monitor/clickhouse_monitor.lua',
         hidden = not ntop.getPrefs().is_dump_flows_to_clickhouse_enabled,
      }
   }

-- Add script entries relative to system health (e.g., redis) ...
for k, entry in pairsByField(page_utils.scripts_menu, "sort_order", rev) do
   -- NOTE: match on the health key to only pick the right subset of entries
   if entry.menu_entry.section == page_utils.menu_sections.health.key then
      health_entries[#health_entries + 1] = {
	 entry = page_utils.menu_entries[entry.menu_entry.key],
	 url = entry.url,
      }
   end
end

page_utils.add_menubar_section({
   hidden = not is_system_interface,
   section = page_utils.menu_sections.health,
   entries = health_entries
})

-- ##############################################

-- Pollers (e.g., SNMP, active monitoring)

local poller_entries = {
   {
      entry = page_utils.menu_entries.infrastructure_dashboard,
      hidden = (not ntop.isEnterpriseL() and not ntop.isnEdgeEnterprise()) or not is_admin,
      url = '/lua/pro/enterprise/infrastructure_dashboard.lua'
   },
   {
      entry = page_utils.menu_entries.snmp,
      hidden = not is_system_interface or (not ntop.isEnterpriseM() and not ntop.isnEdgeEnterprise()),
      url = "/lua/pro/enterprise/snmpdevices_stats.lua",
   },
   {
      entry = page_utils.menu_entries.active_monitoring,
      hidden = not is_system_interface,
      url = "/lua/monitor/active_monitoring_monitor.lua",
   }
}

-- Add script entries relative to pollers (e.g., active monitoring) ...
for k, entry in pairsByField(page_utils.scripts_menu, "sort_order", rev) do
   if entry.menu_entry.section == page_utils.menu_sections.pollers.key then
      poller_entries[#poller_entries + 1] = {
	 entry = page_utils.menu_entries[entry.menu_entry.key],
	 url = entry.url,
      }
   end
end

page_utils.add_menubar_section({
   hidden = not is_system_interface,
   section = page_utils.menu_sections.pollers,
   entries = poller_entries
})

-- ##############################################

-- System

local system_entries = {}

-- Add script entries...
for k, entry in pairsByField(page_utils.scripts_menu, "sort_order", rev) do
   -- Skip pollers, they've already been set under pollers section
   if not entry.menu_entry.section == "pollers" then
      system_entries[#system_entries + 1] = {
	 entry = page_utils.menu_entries[entry.menu_entry.key],
	 url = entry.url,
      }
   end
end

-- Possibly add nEdge entries
if is_nedge or is_appliance then
   -- Possibly add a divider if system_entries already contain elements
   if #system_entries > 0 then
      system_entries[#system_entries + 1] = {
	 entry = page_utils.menu_entries.divider,
	 hidden = not is_admin,
      }
   end
end

if is_nedge then
   for _, entry in ipairs(
      {
	 {
	    entry = page_utils.menu_entries.system_setup,
	    hidden = not is_admin,
	    url = '/lua/system_setup_ui/interfaces.lua',
	 },
	 {
	    entry = page_utils.menu_entries.dhcp_static_leases,
	    hidden = not is_admin or not ntop.isRoutingMode(),
	    url = '/lua/pro/nedge/admin/dhcp_leases.lua',
	 },
	 {
	    entry = page_utils.menu_entries.dhcp_active_leases,
	    hidden = not is_admin or not ntop.isRoutingMode(),
	    url = '/lua/pro/nedge/admin/dhcp_active_leases.lua',
	 },
	 {
	    entry = page_utils.menu_entries.port_forwarding,
	    hidden = not is_admin or not ntop.isRoutingMode(),
	    url = '/lua/pro/nedge/admin/port_forwarding.lua',
	 },
   }) do
      system_entries[#system_entries + 1] = entry
   end
end

if is_appliance then
   for _, entry in ipairs(
      {
	 {
	    entry = page_utils.menu_entries.system_setup,
	    hidden = not is_admin,
	    url = '/lua/system_setup_ui/mode.lua',
	 },
   }) do
      system_entries[#system_entries + 1] = entry
   end
end

if #system_entries > 0 then
   page_utils.add_menubar_section(
      {
	 section = page_utils.menu_sections.system_stats,
	 hidden = not isAllowedSystemInterface() or not is_system_interface,
	 entries = system_entries,
      }
   )
end

-- ##############################################

-- Pools

page_utils.add_menubar_section({
   hidden = not is_system_interface,
   section = page_utils.menu_sections.pools,
   entries = {
      {
         entry = page_utils.menu_entries.manage_pools,
         hidden = not is_admin,
         url = '/lua/admin/manage_pools.lua'
      },
      {
         entry = page_utils.menu_entries.host_members,
         hidden = not is_admin,
         url = '/lua/admin/manage_host_members.lua',
      }
   }
})

-- ##############################################

page_utils.add_menubar_section({
   section = page_utils.menu_sections.notifications,
   hidden = not is_system_interface,
   entries = {
      {
         entry = page_utils.menu_entries.endpoint_notifications,
         hidden = not is_admin,
         url = '/lua/admin/endpoint_notifications_list.lua',
      },
      {
         entry = page_utils.menu_entries.endpoint_recipients,
         hidden = not is_admin,
         url = '/lua/admin/recipients_list.lua',
      }
   }
})

-- ##############################################

-- Admin
page_utils.add_menubar_section(
   {
      section = page_utils.menu_sections.admin,
      hidden = not is_admin,
      entries = {
	 {
	    entry = page_utils.menu_entries.nedge_users,
	    hidden = not is_admin or not is_nedge,
	    url = '/lua/pro/nedge/admin/nf_list_users.lua',
	 },
	 {
	    entry = page_utils.menu_entries.manage_users,
            -- Note: 'not _SESSION["localuser"]' indicates that this is an external
            -- user (e.g. LDAP), in that case allow users management if fallback is enabled.
	    hidden = not is_admin or (not _SESSION["localuser"] and not has_local_auth),
	    url = '/lua/admin/users.lua',
	 },
	 {
	    entry = page_utils.menu_entries.preferences,
	    hidden = not is_admin,
	    url = '/lua/admin/prefs.lua',
	 },
         {
            entry = page_utils.menu_entries.license,
            hidden = info["pro.forced_community"],
            url = '/lua/license.lua',
         },
	 {
	    entry = page_utils.menu_entries.divider,
	 },
	 {
	    entry = page_utils.menu_entries.scripts_config,
	    section = page_utils.menu_sections.checks,
	    hidden = not is_admin or not auth.has_capability(auth.capabilities.checks),
	    url = '/lua/admin/edit_configset.lua?subdir=all',
	 },
	 {
	    entry = page_utils.menu_entries.alert_exclusions,
	    section = page_utils.menu_sections.checks,
	    hidden = not is_admin or not auth.has_capability(auth.capabilities.checks) or not ntop.isEnterpriseM(),
	    url = '/lua/pro/admin/edit_alert_exclusions.lua?subdir=host',
	 },
	 {
	    entry = page_utils.menu_entries.divider,
	 },
	 {
	    entry = page_utils.menu_entries.manage_configurations,
	    hidden = not is_admin or is_windows,
	    url = '/lua/admin/manage_configurations.lua',
	 },
	 {
	    entry = page_utils.menu_entries.manage_data,
	    hidden = not is_admin,
	    url = '/lua/manage_data.lua',
	 },
	 {
	    entry = page_utils.menu_entries.divider,
	 },
	 {
	    entry = page_utils.menu_entries.profiles,
	    hidden = not is_admin or not ntop.isPro() or is_nedge,
	    url = '/lua/pro/admin/edit_profiles.lua',
	 },
	 {
	    entry = page_utils.menu_entries.categories,
	    hidden = not is_admin,
	    url = '/lua/admin/edit_categories.lua',
	 },
	 {
	    entry = page_utils.menu_entries.category_lists,
	    hidden = not is_admin,
	    url = '/lua/admin/edit_category_lists.lua',
	 },
	 {
	    entry = page_utils.menu_entries.device_protocols,
	    hidden = not is_admin,
	    url = '/lua/admin/edit_device_protocols.lua',
	 },
      },
   }
)

-- ##############################################

-- Developer


if not info.oem and auth.has_capability(auth.capabilities.developer) then
   page_utils.add_menubar_section(
      {
	 section = page_utils.menu_sections.dev,
	 entries = {
	    {
	       entry = page_utils.menu_entries.checks_dev,
	       url = '/lua/checks_overview.lua',
	    },
	    {
	       entry = page_utils.menu_entries.alert_definitions,
	       url = '/lua/defs_overview.lua',
	    },
	    {
	       entry = page_utils.menu_entries.directories,
	       url = '/lua/directories.lua',
	    },
	    {
	       entry = page_utils.menu_entries.api,
	       url = 'https://www.ntop.org/guides/ntopng/api/',
	    },

	 },
      }
   )
end

-- ##############################################

-- About
page_utils.add_menubar_section(
   {
      section = page_utils.menu_sections.about,
      hidden = info.oem,
      entries = {
         {
            entry = page_utils.menu_entries.about,
            url = '/lua/about.lua',
         },
         {
            entry = page_utils.menu_entries.telemetry,
            url = '/lua/telemetry.lua',
         },
         {
            entry = page_utils.menu_entries.blog,
            url = 'http://blog.ntop.org/',
         },
         {
            entry = page_utils.menu_entries.telegram,
            url = 'https://t.me/ntop_community',
         },

         {
            entry = page_utils.menu_entries.manual,
            url = 'https://www.ntop.org/guides/ntopng/',
         },
         {
            entry = page_utils.menu_entries.divider
         },
         {
            entry = page_utils.menu_entries.report_issue,
            url = 'https://github.com/ntop/ntopng/issues',
         },
         {
            entry = page_utils.menu_entries.suggest_feature,
            url = 'https://www.ntop.org/support/need-help-2/contact-us/',
         }
      },
   }
)

-- ##############################################

page_utils.print_menubar()

-- ##############################################
-- Interface

print([[
   <nav style="margin-top:-4.5rem;margin-right:5rem;" class="navbar navbar-expand-lg navbar-light px-2 navbar-main-top" id='n-navbar'>
      <ul class='navbar-nav flex-row flex-wrap navbar-main-top'>
         <li class='nav-item'>
            <button class='btn btn-outline-dark border-0 btn-sidebar' data-bs-toggle='sidebar'>
               <i class="fas fa-bars"></i>
            </button>
         </li>
 ]])

-- ##############################################
-- Interfaces Selector

local views = {}
local drops = {}
local recording = {}
local packetinterfaces = {}
local zmqinterfaces = {}
local pcapdump = {}
local ifnames = {}
local iftype = {}
local ifHdescr = {}
local observationPoints = nil
local ifCustom = {}
local dynamic = {}
local action_urls = {}

for v,k in pairs(iface_names) do
   interface.select(k)
   local _ifstats = interface.getStats()
   ifnames[_ifstats.id] = k
   action_urls[_ifstats.id] = page_utils.switch_interface_form_action_url(ifId, _ifstats.id, _ifstats.type)
   --io.write("["..k.."/"..v.."][".._ifstats.id.."] "..ifnames[_ifstats.id].."=".._ifstats.id.."\n")
   if interface.isPcapDumpInterface() then pcapdump[k] = true end
   if(_ifstats.isView == true) then views[k] = true end
   if(interface.isSubInterface()) then dynamic[k] = true end
   if(recording_utils.isEnabled(_ifstats.id)) then recording[k] = true end
   if(interface.isPacketInterface()) then packetinterfaces[k] = true end
   if(interface.isZMQInterface()) then zmqinterfaces[k] = true end
   if(_ifstats.stats_since_reset.drops * 100 > _ifstats.stats_since_reset.packets) then
      drops[k] = true
   end

   ifCustom[_ifstats.id] = _ifstats.customIftype

   local descr = getHumanReadableInterfaceName(v)

   if ntop.isWindows() and string.contains(descr, "{") then -- Windows
      descr = _ifstats.description
   elseif ntop.isEnterpriseM() and interface.isSubInterface() and _ifstats.dynamic_interface_probe_ip then
      -- Attempt at printing SNMP information rather than plain disaggregated IPs
      local snmp_utils = require "snmp_utils"
      local snmp_cached_dev = require "snmp_cached_dev"
      local cached_device = snmp_cached_dev:create(_ifstats.dynamic_interface_probe_ip)
      local snmp_name, snmp_if_name

      if cached_device then
	 -- See if there is a name for this probe in SNMP
	 if cached_device.system and cached_device.system.name then
	    snmp_name = cached_device.system.name

	    -- Now check for the existance of the interface name
	    if _ifstats.dynamic_interface_inifidx then
	       if cached_device.interfaces and cached_device.interfaces[tostring(_ifstats.dynamic_interface_inifidx)] then
		  snmp_if_name = snmp_utils.get_snmp_interface_label(cached_device.interfaces[tostring(_ifstats.dynamic_interface_inifidx)], true)
	       else
		  snmp_if_name = _ifstats.dynamic_interface_inifidx
	       end
	    end
	 end
      end
      if snmp_name then
	 -- Something has been found in SNMP
	 local fmt = ""

	 if snmp_if_name then
	    -- There's the interface name as well
	    fmt = string.format("%s [%s]", snmp_name, snmp_if_name)
	 else
	    -- Only the device name
	    fmt = string.format("%s", snmp_name)
	 end

	 if descr ~= _ifstats.description then
	    -- There's a custom alias
	    descr = string.format("%s (%s)", descr, fmt)
	 else
	    descr = fmt
	 end
      end
   else
      if descr ~= _ifstats.description and not views[k] and not pcapdump[k] then
      	 if descr == shortenCollapse(_ifstats.description) then
      	    descr = _ifstats.description
      	 else
            if prefs.is_interface_name_only == false then
	       -- Removed description that can be long with ZMQ
      	      descr = descr -- .. " (".. _ifstats.description ..")" -- Add description
            end
      	 end
      end
   end

--   tprint({k, dynamic[k], _ifstats.dynamic_interface_probe_ip, _ifstats.dynamic_interface_inifidx})

    ifHdescr[_ifstats.id] = descr

    if(ifs.id == _ifstats.id) then
      observationPoints = interface.getObsPointsInfo()["ObsPoints"] or {}
   end
end

-- The observationPoint menu is displayed only for the flow page
if (table.len(observationPoints) > 0)
   and ((page_utils.get_active_section() == "flows")
      or ((page_utils.get_active_section() == "hosts") and (string.contains(_SERVER.QUERY_STRING, "page=flows")))) then
   observationPointId = ntop.getUserObservationPointId()
   if((observationPointId == 0) and (_GET["observationPointId"] ~= 0)) then
      observationPointId = _GET["observationPointId"]
   end
else
   observationPoints = nil
end

interface.select(ifs.id.."")

local infrastructures = {}

if ntop.isEnterpriseM() then
   local infrastructure_utils = require("infrastructure_utils")
   if ntop.isPro() then
      for _, v in pairs(infrastructure_utils.get_all_instances()) do
         infrastructures[v.alias] = v.url
      end
   end
end

local context = {
   ifnames = ifnames,
   infrastructures = infrastructures, 
   views = views,
   dynamic = dynamic,
   recording = recording,
   pcapdump = pcapdump,
   packetinterfaces = packetinterfaces,
   zmqinterfaces = zmqinterfaces,
   drops = drops,
   ifHdescr = ifHdescr,
   ifCustom = ifCustom,
   action_urls = action_urls,
   is_system_interface = is_system_interface,
   currentIfaceId = ifs.id,
   observationPoints = observationPoints,
   observationPointId = observationPointId
}

print(template_utils.gen("pages/components/ifaces-dropdown.template", context))


-- ##############################################
-- Up/Down info
if not is_pcap_dump and not is_system_interface then

   print([[
      <li class='nav-item d-none d-sm-done d-md-flex d-lg-flex p-2'>
         <div class='info-stats'>
            ]].. page_utils.generate_info_stats() ..[[
         </div>
      </li>
   ]])

end

-- License Badge
local info = ntop.getInfo(true)

if (_POST["ntopng_license"] == nil) and (info["pro.systemid"] and (info["pro.systemid"] ~= "")) then

   if (info["pro.release"]) then

      if (info["pro.demo_ends_at"] ~= nil) then

         local rest = info["pro.demo_ends_at"] - os.time()

         if (rest > 0) then
            print('<li class="nav-item nav-link"><a href="https://shop.ntop.org"><span class="badge bg-warning">')
            print(" " .. i18n("about.licence_expires_in", {time=secondsToTime(rest)}))
            print('</span></a></li>')
         end
      end

   else
      if(not(ntop.getInfo()["pro.forced_community"])) then
         print('<li class="nav-item nav-link"><a class="ntopng-external-link" href="https://shop.ntop.org" class="badge bg-warning text-decoration-none">')
         print(i18n("about.upgrade_to_professional")..' <i class="fas fa-external-link-alt"></i>')
         print('</a></li>')
      end
   end
end

-- ########################################
-- Network Load
print([[
   <li class="network-load d-none d-lg-inline py-2"></li>
]])

-- ########################################
-- end of navbar-nav
print('</ul>')

print([[
<ul class='navbar-nav flex-row ms-auto my-2'>
]])

-- ########################################
-- Searchbox hosts
-- append searchbox

print("<li class='nav-item'>")
print(
    template_utils.gen("typeahead_input.html", {
        typeahead={
            base_id     = "host_search",
            action      = "", -- see makeFindHostBeforeSubmitCallback
            json_key    = "ip",
            query_field = "host",
            class       = "typeahead-dropdown-right",
            query_url   = ntop.getHttpPrefix() .. "/lua/rest/v2/get/host/find.lua",
            query_title = i18n("search_host"),
            style       = "width: 20rem",
            before_submit = [[NtopUtils.makeFindHostBeforeSubmitCallback("]] .. ntop.getHttpPrefix() .. [[")]],
            max_items   = "'all'" --[[ let source script decide ]],
            parameters  = { ifid = ternary(is_system_interface, getSystemInterfaceId(), ifId) },
        }
    })
)
print("</li>")

-- #########################################
-- User Navbar Menu

-- Render Blog Notifications
if (not info.oem) then

   local username = _SESSION["user"] or ''
   if (isNoLoginUser()) then username = 'no_login' end

   local posts, new_posts_counter = blog_utils.readPostsFromRedis(username)
   template_utils.render("pages/components/blog-dropdown.template", {
      posts = posts,
      new_posts_counter = new_posts_counter,
      username = username
   })
end

local is_no_login_user = isNoLoginUser()

print([[
   <li class="nav-item dropdown">
      <a href='#' class="nav-link dropdown-toggle dark-gray" id='manage-user-dropdown' role="button" data-bs-toggle="dropdown" aria-expanded="false">
         <i class='fas fa-user'></i>
      </a>
      <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-lg-end" aria-labelledby='manage-user-dropdown'>]])

if (not _SESSION["localuser"] or not is_admin) and (not is_no_login_user) then
   print[[
      <li>
         <a class="dropdown-item" href='#password_dialog' data-bs-toggle='modal'>
            <i class='fas fa-user'></i> ]] print(i18n("manage_users.manage_user_x", {user = _SESSION["user"]})) print[[
         </a>
      </li>
   ]]
else

   if (not is_no_login_user) then
      print([[<li><a class="dropdown-item" href=']].. ntop.getHttpPrefix() ..[[/lua/admin/users.lua?user=]].. session_user:gsub("%.", "\\\\\\\\.") ..[['><i class='fas fa-user'></i> ]].. session_user ..[[</a></li>]])
   else
      print([[<li class='dropdown-item disabled'>]])
      print([[<i class='fas fa-user'></i> ]].. session_user ..[[]])
      print([[</li>]])
   end

end

-- Render nendge services
if is_nedge and is_admin then
print([[
   <li class="dropdown-divider"></li>
   <li class="dropdown-header">]] .. i18n("nedge.product_status", {product=info.product}) .. [[</li>
   <li>
      <a class="dropdown-item" href="#poweroff_dialog" data-bs-toggle="modal">
         <i class="fas fa-power-off"></i> ]]..i18n("nedge.power_off")..[[
      </a>
   </li>
   <li>
      <a class="dropdown-item" href="#reboot_dialog" data-bs-toggle="modal">
         <i class="fas fa-redo"></i> ]]..i18n("nedge.reboot")..[[
      </a>
   </li>
]])
end

-- Render Update Menu
if hasSoftwareUpdatesSupport() then
print([[
   <li class="dropdown-divider"></li>
   <li class="dropdown-header" id="updates-info-li">]] .. i18n("updates.no_updates") .. [[.</li>
   <li><a class='dropdown-item' href='#' id="updates-install-li"><i class="fas fa-sync"></i> ]] .. (i18n("updates.check"))  ..[[</a></li>
]])
end

-- Rende Toggle Dark theme menu button

local theme_selector = ntop.getPref("ntopng.user." .. session_user .. ".theme")
local theme_selected = i18n("toggle_dark_theme")

if(theme_selector == 'dark') then
   theme_selected = i18n("toggle_white_theme")
end

print([[
   <li class='dropdown-divider'></li>
   <li>
      <a class='dropdown-item toggle-dark-theme' href='#'><i class="fas fa-adjust"></i> ]].. theme_selected ..[[</a>
   </li>
]])

-- Logout

if(not is_no_login_user) then
   print[[

 <li class='dropdown-divider'></li>
 <li>
   <a class="dropdown-item" href="]]
   print(ntop.getHttpPrefix())
   print [[/lua/ntopng_logout.lua" onclick="return confirm(']] print(i18n("login.logout_message")) print [[')"><i class="fas fa-sign-out-alt"></i> ]] print(i18n("login.logout")) print[[</a></li>]]
 end

 -- Restart menu, the restart JS code can be found inside footer.lua
if(is_admin and ntop.isPackage() and not ntop.isWindows()) then
   print [[
       <li class="dropdown-divider"></li>
       <li><a class="dropdown-item restart-service" href="#"><i class="fas fa-redo-alt"></i> ]] print(i18n("restart.restart")) print[[</a></li>
   ]]
end

print([[
      </ul>
   </li>
</ul>

   </nav>
]])

-- begging of #n-container
print([[<main id='n-container' class='px-md-4 px-sm-1'>]])

-- ###################################################
-- Render toasts
toasts_manager.render_toasts("main-container", toasts_manager.load_main_toasts())
-- ###################################################

print("<div class='main-alerts'>")

-- Hidden by default, will be shown by the footer if necessary
print('<div id="influxdb-error-msg" class="alert alert-danger alert-dismissable" style="display:none" role="alert"><i class="fas fa-exclamation-triangle fa-lg" id="alerts-menu-triangle"></i> <span id="influxdb-error-msg-text"></span>')
print[[<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>]]
print('</div>')

-- Hidden by default, will be shown by the footer if necessary
print('<div id="major-release-alert" class="alert alert-info" style="display:none" role="alert"><i class="fas fa-cloud-download-alt" id="alerts-menu-triangle"></i> <span id="ntopng_update_available"></span>')
print('</div>')

-- See if we are starting up and display an informative message
local secs_to_first_data = interface.getSecsToFirstData()

-- Do not show messages that stay too short on screen (5 sec or more)
if secs_to_first_data > 5 then
   print[[
<div class="alert alert-primary" role="alert" id='starting-up-msg'>
  <div class="spinner-border spinner-border-sm text-primary" role="status">
    <span class="sr-only">Loading...</span>
  </div> ]] print(i18n("restart.just_started", {product = info.product, when = format_utils.secondsToTime(secs_to_first_data), url = "https://www.ntop.org/guides/ntopng/basic_concepts/stats.html"})) print [[
</div>

<script type="text/javascript">
  const msecs_to_first_data = ]] print(string.format("%u", secs_to_first_data * 1000)) print[[;
  const hide_starting_up_msg = function() {
    $("#starting-up-msg").hide();
  };
  setTimeout(hide_starting_up_msg, msecs_to_first_data);
</script>
]]
end

if(_SESSION["INVALID_CSRF"]) then
  print('<div class="alert alert-warning alert-dismissable" role="alert"><i class="fas fa-exclamation-triangle fa-lg" id="alerts-menu-triangle"></i> ')
  print(i18n("expired_csrf"))
  print[[<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>]]
  print('</div>')
end

-- end of main alerts
print("</div>")

-- append password change modal
if(not is_admin) then
   dofile(dirs.installdir .. "/scripts/lua/inc/password_dialog.lua")
end

