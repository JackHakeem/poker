-- bindtoken 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	chan = kChan,
    	version = kVersion,
    	gorderid = params.gorderid,
    	purdata = params.purdata,
    	signature = params.signature,
    	pid = params.pid,
    	orderid = params.orderid,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("gconsume");
end

function proc.response(ret, params )
	print("gconsume init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            data.data.add = tonumber(data.data.add)
            data.data.money = tonumber(data.data.money)
            data.data.score = tonumber(data.data.score)
        end
        return data
    end

end

return proc