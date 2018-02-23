-- goods
local proc = {}

function proc.request(cmd,params)
    local data = {
    	mid = tt.owner:getUid()
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("goods");
end

function proc.response(ret, params )
	print("goods init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        if data.ret == 0 then
            for _,list in ipairs(data.data) do
                list.mid = tonumber(list.mid)
                list.stime = tonumber(list.stime)
                list.expire = tonumber(list.expire)
                list.type = tonumber(list.type)
            end
        end
        return data
    end

end

return proc