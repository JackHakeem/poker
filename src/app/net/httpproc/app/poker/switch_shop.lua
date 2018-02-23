-- switch_shop 商城开关
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("switch_shop");
end

function proc.response(ret, params )
	print("switch_shop init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
        	--商城开关，0关闭，1打开
            data.data.is_shop = tonumber(data.data.is_shop)
        end
        return data
    end

end

return proc