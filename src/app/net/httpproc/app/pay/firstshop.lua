local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid(),
    	chan = kChan,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("firstshop");
end

function proc.response(ret, params )
	print("firstshop init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
        	data.data.pmodes = json.decode(data.data.pmode)
        	for i,pmode in ipairs(data.data.pmodes) do
        		data.data.pmodes[i] = tonumber(pmode)
        	end
        	data.data.pmode = data.data.pmodes[1] or 0
            data.data.coin = tonumber(data.data.coin)
            data.data.old_coin = tonumber(data.data.old_coin)
            if data.data.extra then
            	data.data.extra = json.decode(data.data.extra)
                if data.data.extra.score then
                    data.data.extra.score = tonumber(data.data.extra.score)
                end
            end
        	dump(data,"firstshop")
        end
        return data
    end

end

return proc