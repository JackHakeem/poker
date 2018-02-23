-- ver_check 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	chan = kChan,
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("ver_check");
end

function proc.response(ret, params )
	print("ver_check init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            data.data.type = tonumber(data.data.type)
        end
        return data
    end

end

return proc