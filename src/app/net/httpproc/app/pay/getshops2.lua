-- bindtoken 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	chan = kChan,
    	version = kVersion,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("getshops2");
end

function proc.response(ret, params )
	print("getshops2 init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            for _,pmodeInfo in ipairs(data.data) do
                pmodeInfo.is_first = checkint(pmodeInfo.is_first)
                pmodeInfo.pmode = tonumber(pmodeInfo.pmode)
                for _,one_goods in ipairs(pmodeInfo.goods) do
                    one_goods.coin = tonumber(one_goods.coin) or 0
                    one_goods.pmode = pmodeInfo.pmode
                    one_goods.type = tonumber(one_goods.type) or 0
                    one_goods.vp = tonumber(one_goods.vp) or 0
                    one_goods.first_vp = checkint(one_goods.first_vp)
                    one_goods.old_coin = tonumber(one_goods.old_coin) or 0
                    one_goods.price_num = tonumber(one_goods.price) or 0
                    if one_goods.type == 1 then

                    elseif one_goods.type == 2 then
                        one_goods.gettype = tonumber(one_goods.gettype) or 0 --额外赠送类型,1筹码，2金币,3道具(小喇叭)
                        one_goods.num = tonumber(one_goods.num) or 0
                        if one_goods.gettype == 1 then
                            one_goods.daygetnum = tonumber(one_goods.daygetnum) or 0
                            one_goods.day = tonumber(one_goods.day) or 0
                        end
                    end

                    if one_goods.extra then
                        if one_goods.extra.score then
                            one_goods.extra.score = tonumber(one_goods.extra.score)
                        end
                    end
                end
               
            end
        end
        return data
    end

end

return proc