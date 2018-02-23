-- everyday_list 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("everyday_list");
end

function proc.response(ret, params )
	print("everyday_list init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)

        if data.ret == 0 then
        	data.data.is_get = tonumber(data.data.is_get)
        	data.data.vp_money = checkint(data.data.vp_money)
        	data.data.gift_money = checkint(data.data.gift_money)
        	data.data.info = data.data.info or {}
        	for _,info in ipairs(data.data.info) do
        		info.day_num = tonumber(info.day_num) or 1
        		info.get_coin = tonumber(info.get_coin) or 0
        		info.get_gold = tonumber(info.get_gold) or 0
        		info.get_score = tonumber(info.get_score) or 0
        		info.status = tonumber(info.status) or 0
        	end
        end
        return data
    end

end

return proc