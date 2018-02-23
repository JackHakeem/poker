-- exchange
local proc = {}

function proc.request(cmd,params)
    local data = {
		vsid = params.vsid,
		pid = params.pid,
		type = params.type,
		mid = tt.owner:getUid(),
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("exchange");
end

function proc.response(ret, params )
	print("exchange init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            data.data.expire = tonumber(data.data.expire)
            if data.data.amount then
                data.data.amount = tonumber(data.data.amount)
            end
            data.data.coin = tonumber(data.data.coin)
            data.data.num = tonumber(data.data.num)
        end
        return data
    end

end

return proc