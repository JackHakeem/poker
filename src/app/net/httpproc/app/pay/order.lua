-- bindtoken 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	chan = kChan,
    	version = kVersion,
    	pmode = params.pmode,
    	pid = params.pid,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("order");
end

function proc.response(ret, params )
	print("order init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            data.data.mid = tonumber(data.data.mid)
        end
        return data
    end

end

return proc