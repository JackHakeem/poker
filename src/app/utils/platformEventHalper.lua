-- Java方法签名中特殊字符/字母含义
-- 特殊字符	数据类型	特殊说明
-- V	void 	一般用于表示方法的返回值
-- Z	boolean	  
-- I	int	  
-- F	float	 
-- [	数组	以[开头，配合其他的特殊字符，表示对应数据类型的数组，几个[表示几维数组
-- L全类名;	引用类型	以L开头、;结尾，中间是引用类型的全类名

local android_cmds = {
	loginFacebook = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "loginFacebook",
		args = {},
		keys = {},
		sig  = "()V"
	},
	loginYouke = {
		className = "com/woyao/youke/YoukeProxy",
		methodName = "loginYouke",
		args = {},
		keys = {},
		sig  = "()V"
	},
	appInvite = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "appInvite",
		args = {},
		keys = {"url"},
		sig  = "(Ljava/lang/String;)V"
	},
	getBatterypercentage = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "getBatterypercentage",
		args = {},
		keys = {},
		sig  = "()I"
	},
	getSignalStrength = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "getSignalStrength",
		args = {},
		keys = {},
		sig  = "()I"
	},
	onProfileSignIn = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "onProfileSignIn",
		args = {},
		keys = {"provider","puid"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V"
	},
	onProfileSignOff = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "onProfileSignOff",
		args = {},
		keys = {},
		sig  = "()V"
	},
	onEvent = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "onEvent",
		args = {},
		keys = {"eventId","jsonStr"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V"
	},
	onEventValue = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "onEventValue",
		args = {},
		keys = {"eventId","jsonStr","value"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;I)V"
	},
	reportError = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "reportError",
		args = {},
		keys = {"error"},
		sig  = "(Ljava/lang/String;)V"
	},
	vibrate = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "vibrate",
		args = {},
		keys = {},
		sig  = "()V"
	},
	startRecord = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "startRecord",
		args = {},
		keys = {"path","what"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V"
	},
	stopRecord = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "stopRecord",
		args = {},
		keys = {},
		sig  = "()V",
	},
	copyToClipboard = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "copyToClipboard",
		args = {},
		keys = {"text"},
		sig  = "(Ljava/lang/String;)I",
	},
	displayWebView = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "displayWebView",
		args = {},
		keys = {"x","y","width","height","showClose"},
		sig  = "(IIIIZ)V",
	},
	dismissWebView = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "dismissWebView",
		args = {},
		keys = {},
		sig  = "()V",
	},
	webViewLoadUrl = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "webViewLoadUrl",
		args = {},
		keys = {"url"},
		sig  = "(Ljava/lang/String;)V",
	},
	isWebViewVisible = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "isWebViewVisible",
		args = {},
		keys = {},
		sig  = "()I",
	},
	getQueueEvent = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "getQueueEvent",
		args = {},
		keys = {},
		sig  = "()V",
	},
	getPushToken = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "getPushToken",
		args = {},
		keys = {},
		sig  = "()Ljava/lang/String;",
	},
	isNotificationEnabled = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "isNotificationEnabled",
		args = {},
		keys = {},
		sig  = "()I",
	},
	gotoSet = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "gotoSet",
		args = {},
		keys = {},
		sig  = "()V",
	},
	removeSplashView = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "removeSplashView",
		args = {},
		keys = {},
		sig  = "()V",
	},
	gotoEvaluate = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "gotoEvaluate",
		args = {},
		keys = {},
		sig  = "()V",
	},
	getBLUUID = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "getBLUUID",
		args = {},
		keys = {},
		sig  = "()Ljava/lang/String;",
	},
	GPayLuaCall = {
		className = "com/woyao/gpay/GPayLuaCall",
		methodName = "Purchase",
		args = {},
		keys = {"sku","orderid"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V",
	},
	getVersionCode = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "getVersionCode",
		args = {},
		keys = {},
		sig  = "()I",
	},
	bluepay_payBySMS = {
		className = "com/woyao/bluepay/BluepayHelper",
		methodName = "payBySMS",
		args = {},
		keys = {"transactionId","price","smsId","propsName"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V",
	},
	bluepay_payByCashcard = {
		className = "com/woyao/bluepay/BluepayHelper",
		methodName = "payByCashcard",
		args = {},
		keys = {"userID","transactionId","propsName","publisherCode"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
	},
	bluepay_payByWallet = {
		className = "com/woyao/bluepay/BluepayHelper",
		methodName = "payByWallet",
		args = {},
		keys = {"userID","transactionId","price","propsName"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
	},
	addLocalNotication = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "addLocalNotication",
		args = {},
		keys = {"title","content","time"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;I)I",
	},
	delLoaclNotication = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "delLoaclNotication",
		args = {},
		keys = {"id"},
		sig  = "(I)V",
	},
	shareLinkToFacebook = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "shareLink",
		args = {},
		keys = {"url","msg"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V",
	},
	sharePhotoToFacebook = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "sharePhoto",
		args = {},
		keys = {},
		sig  = "()V",
	},
	shareOpenGraph = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "shareOpenGraph",
		args = {},
		keys = {"url","title","bmpPath"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
	},
	fbAppInvite = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "appInvite",
		args = {},
		keys = {"appLinkUrl","previewImageUrl"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
	},
	fbGetInvitableFriends = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "getInvitableFriends",
		args = {},
		keys = {},
		sig  = "()Ljava/lang/String;",
	},
	fbInvitabelFriends = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "invitabelFriends",
		args = {},
		keys = {"to","mid","msg"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
	},
	fbGetAllRequestsForReward = {
		className = "com/woyao/facebook/FacebookProxy",
		methodName = "getAllRequestsForReward",
		args = {},
		keys = {},
		sig  = "()V",
	},
	sysShareString = {
		className = "com/woyao/luaevent/LuaEventProxy",
		methodName = "sysShareString",
		args = {},
		keys = {"msg","url"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V",
	}
}

local ios_cmds = {
	loginFacebook = {
		className = "FacebookHelper",
		methodName = "loginFacebook",
		args = {},
	},
    setLuaCallBackFunc = {
        className = "LuaEventProxy",
        methodName = "setLuaCallBackFunc",
        args = {},
    },
    loginYouke = {
	 	className = "YoukeHelper",
	 	methodName = "loginYouke",
	 	args = {},
    },
    storekit = {
	 	className = "StorekitHelper",
	 	methodName = "buyProduct",
	 	args = {
	 		productID = "",
	 		pid = "",
	 		orderid = "",
	 		pmode = "",
	 	},
    },
    getBatterypercentage = {
	 	className = "LuaEventProxy",
	 	methodName = "getBatterypercentage",
	 	args = {},
	},
	getSignalStrength = {
	 	className = "LuaEventProxy",
	 	methodName = "getSignalStrength",
	 	args = {},
	},
	onProfileSignIn = {
        className = "LuaEventProxy",
        methodName = "onProfileSignIn",
        args = {},
    },
	onProfileSignOff = {
        className = "LuaEventProxy",
        methodName = "onProfileSignOff",
        args = {},
    },
	onEvent = {
        className = "LuaEventProxy",
        methodName = "onEvent",
        args = {},
    },
	onEventValue = {
        className = "LuaEventProxy",
        methodName = "onEventValue",
        args = {},
    },
	reportError = {
        className = "LuaEventProxy",
        methodName = "reportError",
        args = {},
    },
	vibrate = {
		className = "LuaEventProxy",
		methodName = "vibrate",
		args = {},
	},
	startRecord = {
		className = "LuaEventProxy",
		methodName = "startRecord",
		args = {},
	},
	stopRecord = {
		className = "LuaEventProxy",
		methodName = "stopRecord",
		args = {},
	},
	copyToClipboard = { 
		className = "LuaEventProxy",
		methodName = "copyToClipboard",
		args = {
			text="",
		},
	},
	displayWebView = {
		className = "LuaEventProxy",
		methodName = "displayWebView",
		args = {
			x=0, 
			y=0,
			width=0,
			height=0,
		},
	},
	dismissWebView = {
		className = "LuaEventProxy",
		methodName = "dismissWebView",
		args = {},
	},
	webViewLoadUrl = {
		className = "LuaEventProxy",
		methodName = "webViewLoadUrl",
		args = {
			url="",
		},
	},
	isWebViewVisible = {
		className = "LuaEventProxy",
		methodName = "isWebViewVisible",
		args = {},
	},
	getPushToken = {
		className = "LuaEventProxy",
		methodName = "getPushToken",
		args = {},
	},
	isNotificationEnabled = {
		className = "LuaEventProxy",
		methodName = "isNotificationEnabled",
		args = {},
	},
	gotoSet = {
		className = "LuaEventProxy",
		methodName = "gotoSet",
		args = {},
	},
	gotoEvaluate = {
		className = "LuaEventProxy",
		methodName = "gotoEvaluate",
		args = {},
	},
	getVersionCode = {
		className = "LuaEventProxy",
		methodName = "getVersionCode",
		args = {},
	},
	addLocalNotication = {
		className = "LuaEventProxy",
		methodName = "addLocalNotication",
		args = {},
	},
	delLoaclNotication = {
		className = "LuaEventProxy",
		methodName = "delLoaclNotication",
		args = {},
	},
	shareLinkToFacebook = {
		className = "FacebookHelper",
		methodName = "shareLink",
		args = {},
	},
	sharePhotoToFacebook = {
		className = "FacebookHelper",
		methodName = "sharePhoto",
		args = {},
	},
	shareOpenGraph = {
		className = "FacebookHelper",
		methodName = "shareOpenGraph",
		args = {},
	},
	fbAppInvite = {
		className = "FacebookHelper",
		methodName = "appInvite",
		args = {},
		keys = {"appLinkUrl","previewImageUrl"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
	},
	fbGetInvitableFriends = {
		className = "FacebookHelper",
		methodName = "getInvitableFriends",
		args = {},
		keys = {},
		sig  = "()Ljava/lang/String;",
	},
	fbInvitabelFriends = {
		className = "FacebookHelper",
		methodName = "invitabelFriends",
		args = {},
		keys = {"to","mid","msg"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;",
	},
	fbGetAllRequestsForReward = {
		className = "FacebookHelper",
		methodName = "getAllRequestsForReward",
		args = {},
		keys = {},
		sig  = "()V",
	},
	sysShareString = {
		className = "LuaEventProxy",
		methodName = "sysShareString",
		args = {},
		keys = {"msg"},
		sig  = "()V",
	}
}

local window_cmds = {
	-- loginFacebook = {args = {},},
	-- loginYouke = {args = {},},
	-- appInvite = {args = {},},
	-- getBatterypercentage = {args = {},},
	-- getSignalStrength = {args = {},},
	-- storekit = {args = {},},
	-- onProfileSignIn = {args = {},},
	-- onProfileSignOff = {args = {},},
	-- onEvent = {args = {},},
	-- onEventValue = {args = {},},
	-- reportError = {args = {},},
}
local mt = {}
mt.__index = function(table, key)
		table[key] = {args = {},}
		return table[key]
	end

setmetatable(window_cmds,mt)


local callbackCmds = {
	loginFacebook = "loginFacebook",
	loginYouke = "loginYouke",
	gpayConsume = "gpayConsume",
	payCallback = "payCallback",
	voiceRecord = "voiceRecord",
	voiceRecordDecibels = "voiceRecordDecibels",
	registerPushTokenChange = "registerPushTokenChange",
	pushMsg = "pushMsg",
	bluepayCallback = "bluepayCallback",
	shareCallback = "shareCallback",
	FBGetInvitableFriendsCallback = "FBGetInvitableFriendsCallback",
	FBGetAllRequestsForReward = "FBGetAllRequestsForReward",
}



local scheduler = require("framework.scheduler")

local function callAndroidEvent(params)
	printInfo("callAndroidEvent start")
	if params then
		printInfo("callEvent %s %s %s", params.className, params.methodName,params.sig)
		dump(params,"callAndroidEvent pre")
		local args = {}
		for i,v in ipairs(params.keys) do
			args[i] = params.args[v]
		end
		dump(args,"callAndroidEvent")
		return luaj.callStaticMethod(params.className, params.methodName,args,params.sig)
	end
	return false,"params is nil"
end

local function callIosEvent(params)
	printInfo("callIosEvent start")
	if params then
        if params.args and next(params.args) then
            return luaoc.callStaticMethod(params.className, params.methodName, params.args)
        else
            return luaoc.callStaticMethod(params.className, params.methodName)
        end
	end
	return false,"params is nil"
end

local function callWindowEvent(params)
	printInfo("callWindowEvent start")
	if params then
        if params == window_cmds.loginYouke then
        	scheduler.performWithDelayGlobal(function()
        		native_event(json.encode({
        				cmd="loginYouke",
        				params=json.encode({
        						ret = 1,
						        device_id = "device_id",
						        imsi = "imsi",
						        apn = "apn",
						        mac_address = "mac_address",
						        system_model = "system_model",
						        system_version = "system_version",
						        url = "file://hall/head_default_img.png",
        					})
        			}))
        	end,0.5)
        	return true
        elseif params == window_cmds.getBatterypercentage then
        	return true,100
        elseif params == window_cmds.getSignalStrength then
        	return true,5
        elseif params == window_cmds.loginFacebook then
        	scheduler.performWithDelayGlobal(function()
	        	native_event(json.encode({
	        			cmd="loginFacebook",
	        			params='{"ret":1,"id":"101658923773077","gender":"male","fb_token":"EAAD7pmhIvjsBAK9TbI4VyRrGeUz0kSFkGWGwr4fDZCqNv6LOmRpVOpB0zixq4HpqQROXKwsmLIgEyVNmJ7nNF0Ilmc31fxxxQBSUJVJVh0CDvv9ZCKmxvNZAZA2QZA8WaokJnuHi6ZBUZANXRwDLYzycTLAZBRg7sc8szbkPFuRyUBZCahSOPVhKDzyDnE3muZCB2hxr6kfZCAH6AZDZD","name":"LUO HAO"}',
	    			})
	        	)
        	end,0.5)
        	return true
        else
			return false,"window is only youke login"
        end
	end
	return false,"params is nil"
end


local function error()
	printInfo("callEvent platform error")
end

local platformEventHalper = {}

if device.platform == "android" then
	platformEventHalper.callEvent = callAndroidEvent
	platformEventHalper.cmds = android_cmds
	platformEventHalper.callbackCmds = callbackCmds
elseif device.platform == "ios" then
	platformEventHalper.callEvent = callIosEvent
	platformEventHalper.cmds = ios_cmds
	platformEventHalper.callbackCmds = callbackCmds
elseif device.platform == "windows" or device.platform == "mac" then
	platformEventHalper.callEvent = callWindowEvent
	platformEventHalper.cmds = window_cmds
	platformEventHalper.callbackCmds = callbackCmds
else
	platformEventHalper.callEvent = error
	platformEventHalper.cmds = {}
	platformEventHalper.callbackCmds = {}
end

return platformEventHalper
