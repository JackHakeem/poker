local proc = {}

function proc.request(cmd,params)
    local data = {
   		fbid = params.id, -- facebook id
        mnick = string.utf8_sub_width(params.name,1,10), --昵称
        fb_token = params.fb_token, --token
        icon = string.urlencode(params.url),
        sex = ( params.gender == "male" and 1 ) or ( params.gender == "female" and 2 ) or 0,   --性别 0-保密 1-男 2-女

        clienttype = tt.http_conf.clienttype,-- 系统类型1:android 2:ios 
        version = tt.http_conf.versions, 
        uuid = params.uuid or tt.getOpenUDID(), -- "B0-83-FE-8A-0B-01",  B0-83-FE-8A-0B-B8
        device_id = params.device_id,
        imsi = params.imsi,
        apn = params.apn,
        mac_address = params.mac_address,
        system_model = params.system_model,
        system_version = params.system_version,
    }
    tt.ghttp.post(cmd,data,kHttpUrl2)
    print("loginfb");
end

function proc.response(ret, params )
	print("loginfb init response：",ret, params)
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return {ret=-1}
    else
        local data = json.decode(params)
        data.data = json.decode(data.data)
        data.data.mstatus = checkint(data.data.mstatus)
        if data.data.mstatus == 1 then
            data.data.is_reg = checkint(data.data.is_reg)
            --local data = rep.data
            tt.owner.uid_ = checkint(data.data.mid)
            -- tt.owner.uid_ = data.mid -10200
            tt.owner.nick_ = data.data.mnick
            tt.owner:setMoney(checkint(data.data.money))
            tt.owner.mtkey_ = data.data.mtkey
            tt.owner.img_url_ = string.urldecode(data.data.icon)
            tt.owner.sex_ = checkint(data.data.sex)
            tt.owner:setFb(true)
            tt.owner:setJuan(0)
            tt.owner:setInviteid(data.data.inviteid)
            tt.nativeData.setIosLock(tonumber(data.data.audit_status) == 1)
            local sinfo = data.data.serverinfo
            if sinfo then
                local host = sinfo.host
                -- local host = "10.0.0.100"
                local port = sinfo.port 
                print("server host:", host , "port:", port);
                tt.gsocket:connect(host,port);
            else
                tt.show_msg(tt.gettext("服務器配置拉取失敗"))
            end
            tt.statisticsHalper.onProfileSignIn(tt.owner.uid_,"youke")
        elseif data.data.mstatus == 2 then
            tt.show_msg(tt.gettext("您的賬號已經被封，請聯係GM" ))
        elseif data.data.mstatus == 3 then
            --服务器维护
        else
            tt.show_msg(tt.gettext("登陸失敗 ：") .. data.data.mstatus)
        end
        return data
    end

end

return proc