-- user_break 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("user_break");
end

function proc.response(ret, params )
	print("user_break init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)


        if data.ret == 0 then
            data.data.status = tonumber(data.data.status)
            if data.data.song_cishu then
                data.data.song_cishu = tonumber(data.data.song_cishu)
            end
            if data.data.coin then
                data.data.coin = tonumber(data.data.coin)
            end
            if data.data.total_cishu then
                data.data.total_cishu = tonumber(data.data.total_cishu)
            end
            if data.data.deng_time then
                data.data.deng_time = tonumber(data.data.deng_time)
            end
        end
        return data
    end

end

return proc