--
-- Author: shineflag
-- Date: 2017-02-14 17:23:06
--
require("app.utils.contants")
require("app.utils.sutils")
local User = require("app.model.User")

tt = tt or {}


tt.log = require("app.utils.log")
tt.gevt = require("app.utils.gevt")
require("app.utils.func")

tt.http_conf = require("app.net.httpconf")
tt.cmd = require("app.net.cmd")
tt.ghttp = require("app.net.ghttp")
tt.gsocket = require("app.net.gsocket")
tt.factory = require("app.utils.factory")
tt.play = require("app.utils.sound")
tt.platformEventHalper = require("app.utils.platformEventHalper")
tt.statisticsHalper = require("app.utils.statisticsHalper")
tt.backEventManager = require("app.utils.backEventManager")
tt.nativeData = require("app.utils.game_data")
tt.voiceRecord = require("app.utils.VoiceRecord")
tt.LayoutUtil = require("app.utils.LayoutUtil")
tt.PushHelper = require("app.libs.PushHelper")

local utils = require("framework.cc.utils.init")

require("app.libs.StaticEvent").init()

if io.exists(LANG) then
	print("init " .. LANG)
	local getStr = assert(utils.Gettext.gettextFromFile(LANG))
	tt.gettext = function(istr,...)
		print(istr)
		local str = getStr(istr)
		local params = {...}
		for i=1,#params do
			local ins = tostring(params[i]) or ""
			str = string.gsub(str,string.format("{s%d}",i),ins)
		end
		return str
	end
else
	print("not " .. LANG)
	tt.gettext = function(istr,...)
		print(istr)
		local str = istr
		local params = {...}
		for i=1,#params do
			local ins = tostring(params[i]) or ""
			str = string.gsub(str,string.format("{s%d}",i),ins)
		end
		return str
	end
end


function tt.newModel(name,...)
	local class = require("app.model." .. name)
	return class.new(...)
end

tt.owner = User.new()
function native_event(msg)
    printInfo("native_event msg", msg)
    local evtData = json.decode(msg)
    evtData.name = tt.gevt.NATIVE_EVENT
    tt.gevt:dispatchEvent(evtData)
end
tt.schedulerHandler = {}
if device.platform == "android" then
    local params = clone(tt.platformEventHalper.cmds.getQueueEvent)
	local scheduler = require("framework.scheduler")
	local handler = scheduler.scheduleUpdateGlobal(function()
			luaj.callStaticMethod(params.className, params.methodName,{},params.sig)
		end)
	table.insert(tt.schedulerHandler,handler)
elseif device.platform == "ios" then
    local params = clone(tt.platformEventHalper.cmds.setLuaCallBackFunc)
    params.args.callback = function(msg)
		local scheduler = require("framework.scheduler")
    	scheduler.performWithDelayGlobal(function()
    		native_event(msg) 
    	end,0)
    end
    tt.platformEventHalper.callEvent(params)
else
end

if device.platform == "ios" then
	function tt.getOpenUDID()
	    local openUdid = tt.game_data.openUdid
	    if not openUdid or openUdid == "" then
	    	tt.nativeData.saveOpenUDID(device.getOpenUDID())
	    end
	    return tt.game_data.openUdid
	end
-- elseif device.platform == "android" then
-- 	--todo
-- 	function tt.getOpenUDID()
-- 		-- return crypto.encodeBase64(os.time().."_woyao")
-- 		local ok,uuid = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.getBLUUID)
-- 	    return crypto.encodeBase64(uuid.."_woyao")
-- 	end
else
	function tt.getOpenUDID()
		-- return crypto.encodeBase64(os.time().."_woyao")
	    return device.getOpenUDID()
	end
end

function tt.clearAll()
	local scheduler = require("framework.scheduler")
	for i,handler in ipairs(tt.schedulerHandler) do
		scheduler.unscheduleGlobal(handler)
	end

	for key,v in pairs( package.loaded ) do
		if string.sub(key,1,4) == "app." and key ~= "app.PokerApp" then
			package.loaded[key] = nil
		elseif key == "config" then
			package.loaded[key] = nil
		-- elseif string.sub(key,1,10) == "framework." then
		-- 	package.loaded[key] = nil
		-- elseif string.sub(key,1,6) == "cocos." then
		-- 	package.loaded[key] = nil
		end
	end

	for key,v in pairs( package.preload ) do
		if string.sub(key,1,4) == "app." and key ~= "app.PokerApp" then
			package.preload[key] = nil
		elseif key == "config" then
			package.preload[key] = nil
		-- elseif string.sub(key,1,10) == "framework." then
		-- 	package.preload[key] = nil
		-- elseif string.sub(key,1,6) == "cocos." then
		-- 	package.preload[key] = nil
		end
	end
end

