local gevt = require("app.utils.gevt")
local platformEventHalper = require("app.utils.platformEventHalper")
local PushHelper = {}
local token = ""
function PushHelper.init()
    gevt:addEventListener(tt.gevt.NATIVE_EVENT, PushHelper.onNativeEvent)
end

function PushHelper.getToken()
	if device.platform == "ios" then
		if token == "" then 
			local ok,ret = platformEventHalper.callEvent(tt.platformEventHalper.cmds.getPushToken)
			if ok then
				return ret
			else
				return ""
			end
		end
		return token
	elseif device.platform == "android" then
		local ok,ret = platformEventHalper.callEvent(tt.platformEventHalper.cmds.getPushToken)
		if ok then
			return ret
		else
			return ""
		end
	else
		return ""
	end
end

function PushHelper.onNativeEvent(evt)
    if evt.cmd == platformEventHalper.callbackCmds.registerPushTokenChange then
    	printInfo("PushHelper:onNativeEvent cmd %s token %s", evt.cmd,evt.params)
        token = evt.params
        if tt.owner:getUid() ~= 0 then
        	PushHelper.bindtoken(token)
        end
    elseif evt.cmd == platformEventHalper.callbackCmds.pushMsg then
    	tt.show_msg(evt.params)
    end
end

function PushHelper.bindtoken(token)
	if token and token ~= "" then
		local params = {}
		params.devicetoken = token
		tt.ghttp.request(tt.cmd.bindtoken,params)
	end 
end

PushHelper.init()
return PushHelper