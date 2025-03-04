/*
 *
 * (C) 2013-22 - ntop.org
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#ifndef _PREFS_H_
#define _PREFS_H_

#include "ntop_includes.h"

class Ntop;
class Flow;

extern void usage();
extern void nDPIusage();

typedef struct {
  char *name, *description;
  int id;
} InterfaceInfo;

class Prefs {
 private:
  u_int8_t num_deferred_interfaces_to_register;
  pcap_direction_t captureDirection;
  char **deferred_interfaces_to_register, *cli;
  char *http_binding_address1, *http_binding_address2;
  char *https_binding_address1, *https_binding_address2;
  bool enable_client_x509_auth, reproduce_at_original_speed;
  char *lan_interface, *wan_interface, *zmq_publish_events_url;
  Ntop *ntop;
  bool enable_dns_resolution, sniff_dns_responses, pcap_file_purge_hosts_flows,
    categorization_enabled, resolve_all_host_ip, change_user, daemonize,
    enable_auto_logout, enable_auto_logout_at_runtime, use_promiscuous_mode,
    enable_ixia_timestamps, enable_vss_apcon_timestamps, enable_interface_name_only,
    enable_users_login, disable_localhost_login,
    service_license_check, enable_sql_log, enable_access_log, log_to_file,
    enable_mac_ndpi_stats, enable_activities_debug, enable_behaviour_analysis,
    enable_asn_behaviour_analysis, enable_network_behaviour_analysis, enable_iface_l7_behaviour_analysis,
    emit_flow_alerts, emit_host_alerts, use_clickhouse;
  u_int32_t behaviour_analysis_learning_period;
  u_int32_t iec60870_learning_period;
  ServiceAcceptance behaviour_analysis_learning_status_during_learning,
    behaviour_analysis_learning_status_post_learning;
  TsDriver timeseries_driver;
  u_int64_t iec104_allowed_typeids[2];  
  u_int32_t auth_session_duration;
  bool auth_session_midnight_expiration;

  u_int32_t non_local_host_max_idle, local_host_cache_duration,
	  local_host_max_idle, pkt_ifaces_flow_max_idle;
  u_int32_t active_local_hosts_cache_interval;
  u_int32_t intf_rrd_raw_days, intf_rrd_1min_days, intf_rrd_1h_days, intf_rrd_1d_days;
  u_int32_t other_rrd_raw_days, other_rrd_1min_days, other_rrd_1h_days, other_rrd_1d_days;
  u_int32_t housekeeping_frequency;
  bool disable_alerts, enable_top_talkers, enable_idle_local_hosts_cache,
    enable_active_local_hosts_cache;
  bool enable_flow_device_port_rrd_creation, enable_observation_points_rrd_creation;
  bool enable_tiny_flows_export;
  bool enable_captive_portal, enable_informative_captive_portal, mac_based_captive_portal;
  bool override_dst_with_post_nat_dst, override_src_with_post_nat_src;
  bool routing_mode_enabled, global_dns_forging_enabled;
  bool device_protocol_policies_enabled, enable_vlan_trunk_bridge;
  bool enable_arp_matrix_generation;
  bool enable_zmq_encryption;
  bool flow_table_time, flow_table_probe_order;
  bool enable_broadcast_domain_too_large;
  u_int32_t max_num_secs_before_delete_alert, alert_page_refresh_rate;
  int32_t max_entity_alerts;
  u_int32_t safe_search_dns_ip, global_primary_dns_ip, global_secondary_dns_ip;
  u_int32_t max_num_packets_per_tiny_flow, max_num_bytes_per_tiny_flow;
  u_int32_t max_extracted_pcap_bytes;
  u_int32_t max_ui_strlen;
  u_int8_t default_l7policy;
  HostMask hostMask;

  u_int32_t max_num_hosts, max_num_flows;
  u_int32_t attacker_max_num_flows_per_sec, victim_max_num_flows_per_sec;
  u_int32_t attacker_max_num_syn_per_sec, victim_max_num_syn_per_sec;
  u_int8_t ewma_alpha_percent;
  u_int http_port, https_port;
  u_int8_t num_interfaces;
  u_int16_t auto_assigned_pool_id;
  bool dump_flows_on_es, dump_flows_on_mysql, dump_flows_on_syslog, dump_flows_on_nindex,
    dump_json_flows_on_disk, load_json_flows_from_disk_to_nindex, dump_ext_json;
#ifdef NTOPNG_PRO
  bool dump_flows_direct;
  bool is_geo_map_score_enabled, is_geo_map_asname_enabled, is_geo_map_alerted_flows_enabled,
    is_geo_map_blacklisted_flows_enabled, is_geo_map_host_name_enabled, 
    is_geo_map_rxtx_data_enabled, is_geo_map_num_flows_enabled;
#endif
  bool enable_runtime_flows_dump; /**< runtime preference to enable/disable flows dump from the UI */
  InterfaceInfo *ifNames;
  char *local_networks;
  bool local_networks_set, shutdown_when_done, simulate_vlans, simulate_macs, ignore_vlans, ignore_macs;
  bool insecure_tls; /**< Unsecure TLS connections a-la curl */
  u_int32_t num_simulated_ips;
  char *data_dir, *install_dir, *docs_dir, *scripts_dir,
	  *callbacks_dir, *pcap_dir
#ifdef NTOPNG_PRO
    , *pro_callbacks_dir
#endif
    ;
  char *categorization_key;
  char *zmq_encryption_pwd;
  char *zmq_encryption_priv_key;
  char *export_endpoint, *export_zmq_encryption_key;
  char *http_prefix;
  char *instance_name;
  char *config_file_path, *ndpi_proto_path;
  char *packet_filter;
  char *user;
  bool user_set;
  char *redis_host;
  char *redis_password;
  char *pid_path;
  char *cpu_affinity, *other_cpu_affinity;
#ifdef __linux__
  cpu_set_t other_cpu_affinity_mask;
#endif
  u_int8_t redis_db_id;
  int redis_port;
  int dns_mode;
  bool json_labels_string_format;
  char *es_type, *es_index, *es_url, *es_user, *es_pwd, *es_host;
  char *mysql_host, *mysql_dbname, *mysql_user, *mysql_pw;
#ifndef WIN32
  int flows_syslog_facility;
#endif
  int mysql_port;
  int clickhouse_tcp_port;
  char *ls_host,*ls_port,*ls_proto;
  bool has_cmdl_trace_lvl; /**< Indicate whether a verbose level 
			      has been provided on the command line.*/
#ifndef HAVE_NEDGE
  bool appliance;
#endif

#ifdef HAVE_PF_RING
  int pfring_cluster_id;
#endif

  char *test_pre_script_path;
  char *test_post_script_path;

#ifdef NTOPNG_PRO
  bool print_maintenance, print_license;
#endif
  bool print_version, print_version_json;

  inline void help()      { usage();     }
  inline void nDPIhelp()  { nDPIusage(); }
  void setCommandLineString(int optkey, const char * optarg);
  int setOption(int optkey, char *optarg);
  int checkOptions();

  void setTraceLevelFromRedis();
  void parseHTTPPort(char *arg);
  char *parseLocalNetworks(char *arg);

  static inline void set_binding_address(char ** const dest, const char * addr) {
    if(dest && addr && addr[0] != '\0') {
      if(*dest) free(*dest);
      *dest = strdup(addr);
    }
  };
  bool getDefaultBoolPrefsValue(const char *pref_key, const bool default_value);
  void refreshBehaviourAnalysis();
  
 public:
  Prefs(Ntop *_ntop);
  virtual ~Prefs();

  bool is_pro_edition();
  bool is_enterprise_m_edition();
  bool is_enterprise_l_edition();
  bool is_nedge_edition();
  bool is_nedge_enterprise_edition();
  
  inline bool is_embedded_edition() {
#ifdef NTOPNG_EMBEDDED_EDITION
    return(true);
#else
    return(false);
#endif
  }
  time_t pro_edition_demo_ends_at();
  inline char* get_local_networks()                     { if (!local_networks_set) return NULL; return(local_networks); };
  inline void disable_dns_resolution()                  { enable_dns_resolution = false;  };
  inline void resolve_all_hosts()                       { resolve_all_host_ip = true;     };
  inline bool is_dns_resolution_enabled_for_all_hosts() { return(resolve_all_host_ip);    };
  inline bool is_dns_resolution_enabled()               { return(enable_dns_resolution);  };
  inline bool is_users_login_enabled()                  { return(enable_users_login);     };
  inline bool is_localhost_users_login_disabled()       { return(disable_localhost_login);};
  inline bool is_log_to_file_enabled()                  { return(log_to_file);            };
  inline void disable_dns_responses_decoding()          { sniff_dns_responses = false;    };  
  inline bool decode_dns_responses()                    { return(sniff_dns_responses);    };
  inline void enable_categorization()                   { categorization_enabled = true;  };
  inline bool is_categorization_enabled()               { return(categorization_enabled); };
  inline bool do_change_user()                          { return(change_user);            };
  inline void dont_change_user()                        { change_user = false;            };
  inline bool is_sql_log_enabled()                      { return(enable_sql_log);         };
  inline bool is_access_log_enabled()                   { return(enable_access_log);      };
  inline void do_enable_access_log(bool state = true)   { enable_access_log = state;      };
  inline bool are_ixia_timestamps_enabled()             { return(enable_ixia_timestamps); };
  inline bool are_vss_apcon_timestamps_enabled()        { return(enable_vss_apcon_timestamps); };
  inline char* get_user()                               { return(user);                   };
  inline void set_user(const char *u)                   { if(user) free(user); user = strdup(u); user_set = true; };
  inline bool is_user_set()                             { return user_set; };
  inline u_int32_t get_num_simulated_ips()        const { return(num_simulated_ips);      };
  inline u_int8_t get_num_user_specified_interfaces()   { return(num_interfaces);         };
  inline bool  do_dump_flows_on_es()                    { return(dump_flows_on_es);       };
  inline bool  do_dump_flows_on_mysql()                 { return(dump_flows_on_mysql);    };
  inline bool  do_dump_flows_on_syslog()                { return(dump_flows_on_syslog);   };
  inline bool  do_dump_flows_on_nindex()                { return(dump_flows_on_nindex);   };
  inline bool  do_dump_extended_json()                  { return(dump_ext_json);          };
  inline bool  do_dump_json_flows_on_disk()             { return(dump_json_flows_on_disk);};
  inline bool  do_load_json_flows_from_disk_to_nindex() { return(load_json_flows_from_disk_to_nindex); };
  inline bool  do_dump_flows() const                    { return(dump_flows_on_es || dump_flows_on_mysql || dump_flows_on_syslog || dump_flows_on_nindex); };

#ifdef NTOPNG_PRO
  inline void  toggle_dump_flows_direct(bool enable)    { dump_flows_direct = enable; };
  inline bool  do_dump_flows_direct()                   { return(dump_flows_direct); };
#endif
  inline bool is_runtime_flows_dump_enabled()     const { return(enable_runtime_flows_dump); };
  inline bool is_flows_dump_enabled()             const { return(do_dump_flows() && is_runtime_flows_dump_enabled()); };
    
  int32_t getDefaultPrefsValue(const char *pref_key, int32_t default_value);
  void getDefaultStringPrefsValue(const char *pref_key, char **buffer, const char *default_value);
  char* get_if_name(int id);
  char* get_if_descr(int id);
  inline const char* get_config_file_path()                   { return(config_file_path); };
  inline const char* get_ndpi_proto_file_path()               { return(ndpi_proto_path); };
  void set_data_dir(char* path)                          { data_dir = path; }
  inline char* get_data_dir()                                 { return(data_dir);       };
  inline char* get_docs_dir()                                 { return(docs_dir);       }; // HTTP docs
  inline const char* get_scripts_dir()                        { return(scripts_dir);    };
  inline const char* get_callbacks_dir()                      { return(callbacks_dir);  };
  void set_callback_dir(char *path)                     { callbacks_dir = path;   };
  inline const char* get_pcap_dir()                           { return(pcap_dir);       };
#ifdef NTOPNG_PRO
  inline const char* get_pro_callbacks_dir()                  { return(pro_callbacks_dir); };
#endif
  inline const char* get_test_pre_script_path()               { return(test_pre_script_path); };
  inline const char* get_test_post_script_path()              { return(test_post_script_path); };
  inline char* get_export_endpoint()                    { return(export_endpoint);};
  inline char* get_export_zmq_encryption_key()          { return(export_zmq_encryption_key); };
  inline char* get_categorization_key()                 { return(categorization_key); };
  inline char* get_http_prefix()                        { return(http_prefix); };
  inline char* get_instance_name()                      { return(instance_name); };

  inline bool  do_auto_logout()                         { return(enable_auto_logout);               };
  inline bool  do_auto_logout_at_runtime()              { return(enable_auto_logout_at_runtime);    };
  inline bool  interface_name_only()                    { return(enable_interface_name_only);       };
  inline bool  do_ignore_vlans()                        { return(ignore_vlans);                     };
  inline bool  do_ignore_macs()                         { return(ignore_macs);                      };
  inline bool  do_simulate_vlans()                      { return(simulate_vlans);                   };
  inline bool  do_simulate_macs()                       { return(simulate_macs);                    };
  inline bool  do_insecure_tls()                        { return(insecure_tls);                     };
  inline char* get_cpu_affinity()                       { return(cpu_affinity);                     };
  inline char* get_other_cpu_affinity()                 { return(other_cpu_affinity);               };
#ifdef __linux__
  inline cpu_set_t* get_other_cpu_affinity_mask()       { return(&other_cpu_affinity_mask); };
#endif
  inline u_int get_http_port()                          { return(http_port);               };
  inline u_int get_https_port()                         { return(https_port);              };
  inline bool  is_client_x509_auth_enabled()            { return(enable_client_x509_auth); };
  inline char* get_redis_host()                         { return(redis_host);     }
  inline char* get_redis_password()                     { return(redis_password); }
  inline u_int get_redis_port()                         { return(redis_port);     };
  inline u_int get_redis_db_id()                        { return(redis_db_id);    };
  inline char* get_pid_path()                           { return(pid_path);       };
  inline char* get_packet_filter()                      { return(packet_filter);  };

  inline u_int32_t get_max_num_hosts()                  { return(max_num_hosts);          };
  inline u_int32_t get_max_num_flows()                  { return(max_num_flows);          };

  inline bool daemonize_ntopng()                        { return(daemonize);              };

  inline u_int32_t get_attacker_max_num_flows_per_sec() { return(attacker_max_num_flows_per_sec); };
  inline u_int32_t get_victim_max_num_flows_per_sec()   { return(victim_max_num_flows_per_sec);   };
  inline u_int32_t get_attacker_max_num_syn_per_sec()   { return(attacker_max_num_syn_per_sec);   };
  inline u_int32_t get_victim_max_num_syn_per_sec()     { return(victim_max_num_syn_per_sec);     };
  inline u_int8_t  get_ewma_alpha_percent()             { return(ewma_alpha_percent);             };

  void add_default_interfaces();
  int loadFromCLI(int argc, char *argv[]);
  int loadFromFile(const char *path);
  void add_network_interface(char *name, char *description);
  inline bool json_labels_as_strings()                        { return(json_labels_string_format);       };
  inline void set_json_symbolic_labels_format(bool as_string) { json_labels_string_format = as_string;   };
  void set_routing_mode(bool enabled);
  virtual void lua(lua_State* vm);
  void reloadPrefsFromRedis();
  void loadInstanceNameDefaults();
  void resetDeferredInterfacesToRegister();
  bool addDeferredInterfaceToRegister(const char *ifname);
  void registerNetworkInterfaces();
  void refreshHostsAlertsPrefs();
  void refreshDeviceProtocolsPolicyPref();
  /* Runtime database dump prefs. Allows the user to toggle flows dump from the UI at runtime. */
  void refreshDbDumpPrefs();

  void bind_http_to_address(const char * addr1, const char * addr2);
  void bind_https_to_address(const char * addr1, const char * addr2);
  void bind_http_to_loopback()  { bind_http_to_address((char*)CONST_LOOPBACK_ADDRESS, (char*)CONST_LOOPBACK_ADDRESS);  };
  inline void bind_https_to_loopback() { bind_https_to_address((char*)CONST_LOOPBACK_ADDRESS, (char*)CONST_LOOPBACK_ADDRESS); };
  inline void get_http_binding_addresses(const char** addr1, const char** addr2) { *addr1=http_binding_address1; *addr2=http_binding_address2; };
  inline void get_https_binding_addresses(const char** addr1, const char** addr2) { *addr1=https_binding_address1; *addr2=https_binding_address2; };

  inline bool checkServiceLicense()              { return(service_license_check); };
  inline void disableServiceLicense()            { service_license_check = false; };
  inline char* get_es_type()  { return(es_type);  };
  inline char* get_es_index() { return(es_index); };
  inline char* get_es_url()   { return(es_url);   };
  inline char* get_es_user()  { return(es_user);  };
  inline char* get_es_pwd()   { return(es_pwd);   };
  const inline char* get_es_host()  { return(es_host);  };
  inline bool shutdownWhenDone() { return(shutdown_when_done); }
  inline void set_promiscuous_mode(bool mode)  { use_promiscuous_mode = mode; };
  inline bool use_promiscuous()         { return(use_promiscuous_mode);  };
  inline char* get_mysql_host()         { return(mysql_host);            };
  inline int get_mysql_port()           { return(mysql_port);            };
  inline int get_clickhouse_tcp_port()  { return(clickhouse_tcp_port);   };
  inline char* get_mysql_dbname()       { return(mysql_dbname);          };
  inline char* get_mysql_tablename()    { return((char*)"flows");        };
  inline char* get_mysql_user()         { return(mysql_user);            };
  inline char* get_mysql_pw()           { return(mysql_pw);              };
#ifndef WIN32
  inline int get_flows_syslog_facility() { return(flows_syslog_facility); };
#endif
  inline char* get_ls_host()            { return(ls_host);               };
  inline char* get_ls_port()		{ return(ls_port);		 };
  inline char* get_ls_proto()		{ return(ls_proto);		 };
  inline char* get_zmq_encryption_pwd() { return(zmq_encryption_pwd);    };
  inline char* get_zmq_encryption_priv_key() { return(zmq_encryption_priv_key); };
  inline bool  is_zmq_encryption_enabled() { return(enable_zmq_encryption); };
  inline char* get_command_line()       { return(cli ? cli : (char*)""); };
  inline char* get_lan_interface()      { return(lan_interface ? lan_interface : (char*)""); };
  inline char* get_wan_interface()      { return(wan_interface ? wan_interface : (char*)""); };
  inline void set_lan_interface(char *iface) { if(lan_interface) free(lan_interface); lan_interface = strdup(iface); };
  inline void set_wan_interface(char *iface) { if(wan_interface) free(wan_interface); wan_interface = strdup(iface); };
  inline bool areMacNdpiStatsEnabled()  { return(enable_mac_ndpi_stats); };
  inline pcap_direction_t getCaptureDirection() { return(captureDirection); };
  inline void setCaptureDirection(pcap_direction_t dir) { captureDirection = dir; };
#ifdef HAVE_PF_RING
  inline bool hasPF_RINGClusterID() { return pfring_cluster_id >= 0; };
  inline int getPF_RINGClusterID()  { return pfring_cluster_id;      };
#endif
  inline bool hasCmdlTraceLevel()      { return has_cmdl_trace_lvl;      };
  inline u_int32_t get_auth_session_duration()          { return(auth_session_duration);  };
  inline bool get_auth_session_midnight_expiration()    { return(auth_session_midnight_expiration);  };
  inline u_int32_t get_housekeeping_frequency()         { return(housekeeping_frequency); };
  inline u_int32_t get_host_max_idle(bool localHost) const { return(localHost ? local_host_max_idle : non_local_host_max_idle);  };
  /* Maximum idleness for hosts with alerts engaged, that is, with ongoing issues. */
  inline u_int32_t get_alerted_host_max_idle()       const { return(local_host_max_idle); /* Treat all hosts as local */         };
  inline u_int32_t get_local_host_cache_duration()      { return(local_host_cache_duration);   };
  inline u_int32_t get_pkt_ifaces_flow_max_idle()       { return(pkt_ifaces_flow_max_idle);    };
  inline bool  are_alerts_disabled()                    { return(disable_alerts);              };
  inline bool  are_top_talkers_enabled()                { return(enable_top_talkers);     };
  inline bool  flow_table_duration_or_last_seen()       { return(flow_table_time);     };
  inline bool  is_idle_local_host_cache_enabled()       { return(enable_idle_local_hosts_cache);    };
  inline bool  is_active_local_host_cache_enabled()     { return(enable_active_local_hosts_cache);  };

  inline bool is_tiny_flows_export_enabled()             { return(enable_tiny_flows_export);            };
  inline bool is_flow_device_port_rrd_creation_enabled() { return(enable_flow_device_port_rrd_creation);};
  inline bool is_observation_points_rrd_creation_enabled() { return(enable_observation_points_rrd_creation);};
  inline bool is_arp_matrix_generation_enabled()         { return(enable_arp_matrix_generation);        };

  inline bool do_override_dst_with_post_nat_dst()     const { return(override_dst_with_post_nat_dst);     };
  inline bool do_override_src_with_post_nat_src()     const { return(override_src_with_post_nat_src);     };
  inline bool are_device_protocol_policies_enabled()  const { return(device_protocol_policies_enabled);   };

  inline bool isVLANTrunkModeEnabled()                const { return(enable_vlan_trunk_bridge);           }
  inline bool isCaptivePortalEnabled()                const { return(enable_captive_portal && !enable_vlan_trunk_bridge); }
  inline bool isInformativeCaptivePortalEnabled()     const { return(enable_informative_captive_portal && !enable_vlan_trunk_bridge); }
  inline bool isMacBasedCaptivePortal()               const { return(mac_based_captive_portal);  }
  inline bool enableActivitiesDebug()                 const { return(enable_activities_debug);   }
  const char * getCaptivePortalUrl();
  const TsDriver getTimeseriesDriver()                const { return(timeseries_driver);         }

  inline u_int8_t  getDefaultl7Policy()                  { return(default_l7policy);  }

  inline u_int32_t get_max_num_packets_per_tiny_flow()       const { return(max_num_packets_per_tiny_flow);       };
  inline u_int32_t get_max_num_bytes_per_tiny_flow()         const { return(max_num_bytes_per_tiny_flow);         };

  inline u_int64_t get_max_extracted_pcap_bytes() { return max_extracted_pcap_bytes; };

  inline u_int32_t get_safe_search_dns_ip()      { return(safe_search_dns_ip);                          };
  inline u_int32_t get_global_primary_dns_ip()   { return(global_primary_dns_ip);                       };
  inline u_int32_t get_global_secondary_dns_ip() { return(global_secondary_dns_ip);                     };
  inline bool      isGlobalDNSDefined()          { return(global_primary_dns_ip ? true : false);        };
  inline HostMask  getHostMask()                 { return(hostMask);                                    };
  inline u_int16_t get_auto_assigned_pool_id()   { return(auto_assigned_pool_id);                       };
  inline u_int16_t is_routing_mode()             { return(routing_mode_enabled);                        };
#ifndef HAVE_NEDGE
  inline bool      is_appliance()                { return(appliance);                                   };
#endif
  inline bool      isGlobalDnsForgingEnabled()   { return(global_dns_forging_enabled);                  };
  inline bool      reproduceOriginalSpeed()      { return(reproduce_at_original_speed);                 };
  inline void      doReproduceOriginalSpeed()    { reproduce_at_original_speed = true;                  };
  inline bool      purgeHostsFlowsOnPcapFiles()  { return(pcap_file_purge_hosts_flows);                 };
  inline void      enableBehaviourAnalysis()     { enable_behaviour_analysis = true;                    };
  inline bool      isBehavourAnalysisEnabled()   { return(enable_behaviour_analysis);                   };
  inline u_int32_t behaviourAnalysisLearningPeriod() { return behaviour_analysis_learning_period;       };
  
  inline bool      isBroadcastDomainTooLargeEnabled()     { return(enable_broadcast_domain_too_large);  };

  inline bool      isASNBehavourAnalysisEnabled()     { return(enable_asn_behaviour_analysis);               };
  inline bool      isNetworkBehavourAnalysisEnabled() { return(enable_network_behaviour_analysis);           };
  inline bool      isIfaceL7BehavourAnalysisEnabled() { return(enable_iface_l7_behaviour_analysis);          };

  inline ServiceAcceptance behaviourAnalysisStatusDuringLearning() { return behaviour_analysis_learning_status_during_learning; };
  inline ServiceAcceptance behaviourAnalysisStatusPostLearning()   { return behaviour_analysis_learning_status_post_learning;   };
  inline u_int64_t* getIEC104AllowedTypeIDs()    { return(iec104_allowed_typeids);                      };
  inline u_int32_t getIEC60870LearingPeriod()    { return(iec60870_learning_period);                    };
  inline bool      dontEmitFlowAlerts()          { return(!emit_flow_alerts);                           };
  inline bool      dontEmitHostAlerts()          { return(!emit_host_alerts);                           };
  inline bool      useClickHouse()               { return(use_clickhouse);                              };
  inline char*     getZMQPublishEventsURL()      { return(zmq_publish_events_url);                      };
  void setIEC104AllowedTypeIDs(const char * protos);
  void validate();
};

#endif /* _PREFS_H_ */

