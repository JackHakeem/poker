-- vstore
local proc = {}

function proc.request(cmd,params)
    local data = {
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("vstore");
end

function proc.response(ret, params )
	print("vstore init response：",ret, params)
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
                for _,info in ipairs(list.vstoreinfo) do
                    info.vlevel = tonumber(info.vlevel)
                    info.num = tonumber(info.num)
                    info.expire = tonumber(info.expire)
                    info.coin = tonumber(info.coin)
                end
            end
        end
        return data
    end

end

return proc