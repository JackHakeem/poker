local proc = {}

function proc.request(cmd,params)
    local data = {
    	chan = kChan,
    	version = kVersion,
    	mid = tt.owner:getUid(),
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("vip_club");
end

function proc.response(ret, params )
	print("vip_club init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
        end
        return data
    end

end

return proc