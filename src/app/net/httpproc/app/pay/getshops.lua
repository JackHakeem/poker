-- bindtoken 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	chan = kChan,
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("getshops");
end

function proc.response(ret, params )
	print("getshops init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            for _,shop in ipairs(data.data) do
                shop.coin = tonumber(shop.coin)
                shop.pmode = tonumber(shop.pmode)
                if shop.extra then
                    if shop.extra.score then
                        shop.extra.score = tonumber(shop.extra.score)
                    end
                end
            end
        end
        return data
    end

end

return proc