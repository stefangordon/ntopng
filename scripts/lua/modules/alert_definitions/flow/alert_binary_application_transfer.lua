--
-- (C) 2019-22 - ntop.org
--

-- ##############################################

local flow_alert_keys = require "flow_alert_keys"

-- Import the classes library.
local classes = require "classes"
-- Make sure to import the Superclass!
local alert = require "alert"

-- ##############################################

local alert_binary_application_transfer = classes.class(alert)

-- ##############################################

alert_binary_application_transfer.meta = {
   alert_key = flow_alert_keys.flow_alert_binary_application_transfer,
   i18n_title = "alerts_dashboard.binary_application_transfer",
   icon = "fas fa-fw fa-file-download",

   has_victim = true,
   has_attacker = true,
}

-- ##############################################

-- @brief Prepare an alert table used to generate the alert
-- @param one_flow_param The first alert param
-- @param another_flow_param The second alert param
-- @return A table with the alert built
function alert_binary_application_transfer:init()
   -- Call the parent constructor
   self.super:init()
end

-- #######################################################

-- @brief Format an alert into a human-readable string
-- @param ifid The integer interface id of the generated alert
-- @param alert The alert description table, including alert data such as the generating entity, timestamp, granularity, type
-- @param alert_type_params Table `alert_type_params` as built in the `:init` method
-- @return A human-readable string
function alert_binary_application_transfer.format(ifid, alert, alert_type_params)
   local res = i18n("alerts_dashboard.binary_application_transfer")

   if alert_type_params and alert_type_params["protos.http.last_url"] then
      local url = alert_type_params["protos.http.last_url"]
      local href = '<a class="ntopng-external-link fa-sm" href= http://' .. url .. ' ><i  class="fas fa-external-link-alt fa-lg"></i></a>'
      local type_icon = ''
      local info = ''

      local extn = alert_type_params["protos.http.last_url"]:sub(-4):lower()

      if extn == ".php" or extn == ".js" or extn == ".html" or extn == ".xml" or extn == ".cgi" then
	 type_icon = '<i class="fas fa-fw fa-file-code"></i>'
      elseif extn == ".png" or extn == ".jpg" then
	 type_icon = '<i class="fas fa-fw fa-file-image"></i>'
      end

      if string.len(url) > 64 then
         url = shortenString(alert_type_params["protos.http.last_url"], 64)
         info = '<i class="fas fa-question-circle" data-bs-toggle="tooltip" data-bs-placement="bottom" title="'..alert_type_params["protos.http.last_url"]..'"></i>'
      end
      res = i18n("alerts_dashboard.binary_application_transfer_url", { 
         url = url,
         type_icon = type_icon,
         info = info,
         href = href,
      })
   end

   return res
end

-- #######################################################

return alert_binary_application_transfer
