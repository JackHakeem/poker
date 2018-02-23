
-- bindtoken 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	devicetoken = params.devicetoken,
    	mobile_type = (device.platform == "android" and 1) or 2
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("bindtoken");
end

function proc.response(ret, params )
	print("bindtoken init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)

        return data
    end

end

return proc