-- active_entrance 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	chan = kChan,
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("active_entrance");
end

function proc.response(ret, params )
	print("active_entrance init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            data.data.song_cishu = tonumber(data.data.song_cishu)
            data.data.coin = tonumber(data.data.coin)
        end
        return data
    end

end

return proc