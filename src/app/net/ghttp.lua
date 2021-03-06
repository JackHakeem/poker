--
-- Author: shineflag
-- Date: 2017-02-14 16:11:13
--
require("app.utils.sutils")
local grequest_id = 0  --全局的http请求id
local default_url =  kHttpUrl2
local procs = {}
local ghttp = {}

ghttp.CODE_OK = 200
ghttp.CODE_PERMISSION = -100  --权限检查错误
ghttp.CODE_PARAM_ERR = -101   --参数错误
ghttp.CODE_PARAM_LESS = -102   --缺少参数 
ghttp.CODE_PARAM_METHOD = -103   --方法错误
ghttp.CODE_REG_ERR = -104   --玩家注册失败 
ghttp.CODE_INFO_ERR = -105   --获取玩家信息失败
ghttp.CODE_AKICK = -106   --被封号 
ghttp.CODE_UPLOAD_ERR = -106   --上传文件格式错误


local function getproc(cmd)
	local http_proc = procs[cmd]
	if not http_proc then
		local key = string.gsub(cmd,"/",".")
		http_proc = require("app.net.httpproc." .. string.lower(key))
		assert(http_proc,string.format("php cmd[%s] not found",cmd))
		procs[cmd] = http_proc
	end

	return http_proc
end

local function request( cmd, ... )

	local http_proc = getproc(cmd)
	if http_proc then
		http_proc.request(cmd,...)
	else

	end
end


local function setDefaultUrl( url )
	default_url = url
end


local function buildData( method,data )
    local post_data = { }
    post_data.appid = kAppid
    post_data.chan = kChan
    post_data.sid = tt.http_conf.sid
    post_data.bid = tt.http_conf.bid
    post_data.mtkey = tt.http_conf.mtkey
    post_data.versions = tt.http_conf.versions
    post_data.mid = tt.owner:getUid()
    post_data.clienttype = tt.http_conf.clienttype
    -- 系统类型1 android 2 android pad 3.ios 4.ios pad
    post_data.lang = tt.http_conf.lang
    post_data.method = method

    if data == nil then
        data = {}
    end



    post_data.param = data
    post_data.sig = string.lower(crypto.md5(data))

    return json.encode(post_data)
end

local function buildUrl(url, method )
	if kHttpUrl2 == url then
		return url .. method
	end
    if string.find(method, "#") then
        local indices = string.find(method, "#");
        local m = "";
        local p = "";
        if indices then
            m = string.sub(method, 1, indices - 1);
            p = string.sub(method, indices + 1);
        end

        if m ~= "" and p ~= "" then
            url = url .. "?m=" .. m .. "&p=" .. p;
        elseif m ~= "" and p == "" then
            url = url .. "?m=" .. m;
        elseif m == "" and p ~= "" then
            url = url .. "?m=" .. p;
        end
    end

    return url;
end


local function post(cmd, data, url)
	function onRequestFinished(event)

		local evt = {}
		evt.name = tt.gevt.EVT_HTTP_RESP
		evt.cmd = cmd
		evt.status = false
		evt.code = 0 

		local http_proc = getproc(cmd)
	    local ok = (event.name == "completed")
	    local request = event.request
	    evt.proc = http_proc
	 	evt.proc_name = event.name

	 	if event.name == "progress" then 
	 		return
	 	elseif event.name == "failed" then
			http_proc.response(-1)
			print("response",request:getErrorCode(), request:getErrorMessage())
	        -- http_proc.response(request:getErrorCode(), request:getErrorMessage())
	        evt.data = {ret=-1}
	        tt.gevt:dispatchEvent(evt)	
	        return
	 	elseif event.name == "completed" then
	 		local code = request:getResponseStatusCode()
		 	print("name",event.name,"code",code)
		    local response;
		    local params="";
		    if code == 200 then
			    evt.status = true
			    response = request:getResponseString() or ""
			    print("response",'"' .. response .. '"')
			    params = string.decode_base64(response)
			    dump(params)
			    if not params then 
			    	evt.status = false
			    	code = -1
			    	printError("onRequestFinished params is null")
			    end
		    end
		    --显示服务端返回的内容  
		   	evt.data = http_proc.response(code,params)
		   	tt.gevt:dispatchEvent(evt)
		else
			http_proc.response(-1)
		   	tt.gevt:dispatchEvent(evt)
	 	end

	    -- if not ok then
	    --     -- 请求失败，显示错误代码和错误消息
	    --     -- 0 是請求進行中
	    --     print("name",event.name,"post",request:getErrorCode())
	    --     if request:getErrorCode() ~= 0 and request:getErrorCode() ~= 200 then
	    -- 	end
	    --     return
	    -- end
	    
	end
	 
	-- 创建一个请求，并以 POST 方式发送数据到服务端
	local rurl = buildUrl(url or default_url, cmd) 
	local vstr = buildData(cmd,data)
	printInfo("post %s %s", vstr,rurl)

	local request = network.createHTTPRequest(onRequestFinished, rurl, "post")

	if request:getState() == 0 then
		request:addPOSTValue("api",string.encode_base64(vstr))
		 
		-- 开始请求。当请求完成时会调用 callback() 函数
		request:setTimeout(20)
		request:start()
	else
		local scheduler = require("framework.scheduler")
		scheduler.performWithDelayGlobal(function()
				local evt = {}
				evt.name = tt.gevt.EVT_HTTP_RESP
				evt.cmd = cmd
				evt.status = false
				evt.code = -2
				tt.gevt:dispatchEvent(evt)
			end,1)
	end
end

local function getGetUrl(data, url)
	local vstr = buildData("get",data)
	return url .. "?api=" .. string.encode_base64(vstr)
end


ghttp.setDefaultUrl = setDefaultUrl
ghttp.post = post
ghttp.request = request
ghttp.getGetUrl = getGetUrl

return ghttp
