-- add_detail
local proc = {}

function proc.request(cmd,params)
    local data = {
    	goods_id=params.goods_id,
    	pid=params.pid,
    	detail=params.detail,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("add_detail");
end

function proc.response(ret, params )
	print("add_detail init response：",ret, params)
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