--
-- Author: shineflag
-- Date: 2017-04-04 19:01:27
--

local GameState = require("framework.cc.utils.GameState")
local function load_data()
    local file_key = "abcd" 
    GameState.init(function(param)

        local encrypt = "abcd" 
    	local return_val = nil 

    	if param.errorCode then
    		print("error:", param.errorCode)
    	else
    		--cryto 
            -- dump(param.values,14,14)
    		if param.name == "save" then 
    			local str  = json.encode(param.values)
                if str == nil then print("false") end
                if encrypt then 
    			    str=crypto.encryptXXTEA(str, encrypt)
                end
    			return_val = {data = str}
    		elseif param.name == "load" then 
    			local str = param.values.data 
                if encrypt then 
                    str = crypto.decryptXXTEA( str , encrypt)
                end
    			print("load:",str)
    			return_val = json.decode(str)
    		end
        end
        return return_val
    end,"data.dat",file_key)

    tt.game_data = GameState.load() or  {}
    -- dump(tt.game_data)
    tt.game_data.blind_table = tt.game_data.blind_table or {}
    tt.game_data.cash_lv_carry = tt.game_data.cash_lv_carry or {}
    tt.game_data.sng_info = tt.game_data.sng_info or {}
    tt.game_data.cash_info = tt.game_data.cash_info or {}
    tt.game_data.shop_info = {}
    tt.game_data.shop_info2 = tt.game_data.shop_info2 or {}
    tt.game_data.mtt_info = tt.game_data.mtt_info or {}
    tt.game_data.request_ship_data = tt.game_data.request_ship_data or {}
    tt.game_data.cacheData = tt.game_data.cacheData or {}
    tt.game_data.vip_info = tt.game_data.vip_info or {}
    tt.game_data.prop_data = tt.game_data.prop_data or {}
    tt.game_data.reward_info = tt.game_data.reward_info or {}
    tt.game_data.dreward_info = tt.game_data.dreward_info or {}
    tt.game_data.mreward_info = tt.game_data.mreward_info or {}
    tt.game_data.local_notication = tt.game_data.local_notication or {}
    tt.game_data.xiazhu_bet_history = tt.game_data.xiazhu_bet_history or {}
    tt.game_data.horn_history = tt.game_data.horn_history or {}
    tt.imageCacheManager = require("app.utils.imageCacheManager")
    tt.imageCacheManager.init()
end

local function save_data()
	return GameState.save(tt.game_data)
end

load_data()

local NativeData = {}

function NativeData.saveOpenUDID(id)
    tt.game_data.openUdid = id
    save_data()
end

function NativeData.saveSngInfo(version,data)
    tt.game_data.sng_info = {}
    for _,v in ipairs(data) do
        tt.game_data.sng_info[v.mlv .. ""] = v
    end
    tt.game_data.sng_info_sort = data
    tt.game_data.sng_info_ver = version
    save_data()
end

function NativeData.getSngInfo(lv)
    return tt.game_data.sng_info[lv .. ""]
end

function NativeData.updateLvSngInfo(lv,data)
    tt.game_data.sng_info[lv .. ""] = data
    save_data()
end

function NativeData.saveMttInfo(match_id,data)
    if tostring(match_id) then
        tt.game_data.mtt_info[tostring(match_id)] = data
    end
    save_data()
end

function NativeData.getMttInfo(match_id)
    if tostring(match_id) then
        return tt.game_data.mtt_info[tostring(match_id)]
    end
end

function NativeData.clearMttInfo()
    tt.game_data.mtt_info = {}
    save_data()
end

function NativeData.saveRewardInfo(reward_id,data)
    if tostring(reward_id) then
        tt.game_data.reward_info[tostring(reward_id)] = data
    end
    save_data()
end

function NativeData.getRewardInfo(reward_id)
    if tostring(reward_id) then
        return tt.game_data.reward_info[tostring(reward_id)]
    end
end

function NativeData.saveDrewardInfo(dreward_id,data)
    if tostring(dreward_id) then
        tt.game_data.dreward_info[tostring(dreward_id)] = data
    end
    save_data()
end

function NativeData.getDrewardInfo(dreward_id)
    if tostring(dreward_id) then
        return tt.game_data.dreward_info[tostring(dreward_id)]
    end
end

function NativeData.saveMrewardInfo(mreward_id,data)
    if tostring(mreward_id) then
        tt.game_data.mreward_info[tostring(mreward_id)] = data
    end
    save_data()
end

function NativeData.getMrewardInfo(mreward_id)
    if tostring(mreward_id) then
        return tt.game_data.mreward_info[tostring(mreward_id)]
    end
end

function NativeData.saveBlindInfo(id,data)
    tt.game_data.blind_table[id] = data
    save_data()
end

function NativeData.saveLoginData(loginType,params)
    tt.game_data.preLoginType = loginType
    tt.game_data.preLoginParams = params
    save_data()
end

function NativeData.saveRequestShipData(params)
    tt.game_data.request_ship_data[params.orderid .. ""] = params
    save_data()
end

function NativeData.clearRequestShipData(orderid)
    tt.game_data.request_ship_data[orderid .. ""] = nil
    save_data()
end

function NativeData.getRequestShipData()
    return tt.game_data.request_ship_data
end

function NativeData.saveCashInfo(version,data)
    tt.game_data.cash_info = data
    tt.game_data.cash_info_ver = version
    save_data()
end

function NativeData.getCashInfo()
    return tt.game_data.cash_info
end

function NativeData.getCashInfoBy(lv)
    for _,v in ipairs(tt.game_data.cash_info) do
        if v.lv == lv then
            return v
        end
    end
end

function NativeData.saveShopInfo(version,data)
    tt.game_data.shop_info2 = data
    tt.game_data.shop_ver = version
    save_data()
end

function NativeData.getShopInfo()
    return tt.game_data.shop_info2
end

function NativeData.saveVipInfo(version,data)
    tt.game_data.vip_info = data
    tt.game_data.vip_ver = version
    save_data()
end

function NativeData.saveCacheDownImageData(data)
    tt.game_data.cacheData = data
    save_data()
end

function NativeData.saveCashLvCarry(lv,carry)
    tt.game_data.cash_lv_carry[lv] = carry
    save_data()
end

function NativeData.saveCashLvSelect(lv)
    tt.game_data.cash_lv_select = lv
    save_data()
end

function NativeData.saveMusicBtnStatus(status)
    tt.game_data.music_btn_status = status
    save_data()
end

function NativeData.saveSoundBtnStatus(status)
    tt.game_data.sound_btn_status = status
    save_data()
end

function NativeData.saveShockBtnStatus(status)
    tt.game_data.shock_btn_status = status
    save_data()
end

function NativeData.savePushBtnStatus(status)
    tt.game_data.push_btn_status = status
    save_data()
end

function NativeData.savePropData(pid,data)
    tt.game_data.prop_data[pid..""] = data
    save_data()
end

function NativeData.getPropData(pid)
    return tt.game_data.prop_data[pid..""]
end

local firstRechargeData = nil
function NativeData.setFirstRecharge(data)
    firstRechargeData = data
end

function NativeData.getFirstRecharge()
    return firstRechargeData
end

local everydayList = nil
function NativeData.setEverydayList(data)
    everydayList = data
end

function NativeData.getEverydayList()
    return everydayList
end

local bankruptcy_data
function NativeData.setBankruptcy(data)
    bankruptcy_data = data
    if bankruptcy_data then
        bankruptcy_data.endTime = tt.time() + bankruptcy_data.deng_time
    end
end

function NativeData.getBankruptcy()
    return bankruptcy_data
end

local ios_lock = true
function NativeData.setIosLock(flag)
    ios_lock = flag
end

function NativeData.isIosLock()
    return ios_lock
end

local vip_shop_lock = true
function NativeData.setVipShopLock(flag)
    vip_shop_lock = flag
end

function NativeData.isVipShopLock()
    return vip_shop_lock
end

function NativeData.saveLocalNotication(data)
    tt.game_data.local_notication = data
    save_data()
end

function NativeData.getLocalNotication()
    return tt.game_data.local_notication
end

function NativeData.getXiazhuSelectIndex()
    return tt.game_data.xiazhu_select_index or 0
end

function NativeData.saveXiazhuSelectIndex(index)
    tt.game_data.xiazhu_select_index = index
    save_data()
end

function NativeData.getXiazhuFactorVersion()
    return tt.game_data.xiazhu_factor_version or 0
end

function NativeData.getXiazhuFactors()
    return tt.game_data.xiazhu_factors or {
        [3] = 1200,
        [4] = 400,
        [5] = 200,
        [6] = 125,
        [7] = 80,
        [8] = 60,
        [9] = 50,
        [10] = 45,
        [11] = 45,
        [12] = 50,
        [13] = 60,
        [14] = 80,
        [15] = 125,
        [16] = 200,
        [17] = 400,
        [18] = 1200,
    }
end

function NativeData.saveXiazhuFactor(version,factors)
    tt.game_data.xiazhu_factor_version = version
    tt.game_data.xiazhu_factors = factors
    save_data()
end

function NativeData.saveXiazhuMinLeft(num)
    tt.game_data.xiazhu_min_left = num
    save_data()
end

function NativeData.saveXiazhuMinUnit(num)
    tt.game_data.xiazhu_min_unit = num
    save_data()
end

function NativeData.getXiazhuMinLeft()
    return tt.game_data.xiazhu_min_left or 0
end

function NativeData.getXiazhuMinUnit()
    return tt.game_data.xiazhu_min_unit or 10000
end

function NativeData.saveXiaZhuBetHistory(data)
    local uid = tt.owner:getUid() .. ""
    tt.game_data.xiazhu_bet_history[uid] = tt.game_data.xiazhu_bet_history[uid] or {}
    table.insert(tt.game_data.xiazhu_bet_history[uid],1,data)
    if #tt.game_data.xiazhu_bet_history[uid] > 100 then
       table.remove(tt.game_data.xiazhu_bet_history[uid],#tt.game_data.xiazhu_bet_history[uid])
    end
    save_data()
end

function NativeData.getXiaZhuBetHistorys()
    local uid = tt.owner:getUid() .. ""
    return tt.game_data.xiazhu_bet_history[uid] or {}
end

function NativeData.updateXiaZhuBetHistoryByLuck(happyid,stage,luck)
    local uid = tt.owner:getUid() .. ""
    local factors = NativeData.getXiazhuFactors()
    local sum = (luck[1] or 0) + (luck[2] or 0) + (luck[3] or 0)
    local factor = factors[tostring(sum)] or factors[sum] or 0

    for i,history in ipairs(tt.game_data.xiazhu_bet_history[uid] or {}) do
        if history.happyid == happyid and history.stage == stage then
            local bets = {}
            for num,coins in pairs(history.bets) do
                num = tonumber(num)
                if num >= 3 and num <= 18 then
                    bets[num] = (bets[num] or 0) + coins
                elseif num == 1 then
                    for i=3,18,2 do
                        bets[i] = (bets[i] or 0) + coins/8
                    end
                elseif num == 19 then
                    for i=3,10,1 do
                        bets[i] = (bets[i] or 0) + coins/8
                    end
                elseif num == 20 then
                    for i=11,18,1 do
                        bets[i] = (bets[i] or 0) + coins/8
                    end
                elseif num == 2 then
                    for i=4,18,2 do
                        bets[i] = (bets[i] or 0) + coins/8
                    end
                end
            end
            history.winscore = ( bets[sum] or 0 ) * factor
            history.luck = luck
        end
    end
    save_data()
end

function NativeData.clearXiaZhuBetHistory(happyid,stage)
    local uid = tt.owner:getUid() .. ""
    local data = {}
    for i,history in ipairs(tt.game_data.xiazhu_bet_history[uid] or {}) do
        if history.happyid == happyid and history.stage == stage then

        else
            table.insert(data,history)
        end
    end
    tt.game_data.xiazhu_bet_history[uid] = data
    save_data()
end

function NativeData.checkXiazhuBetHistory(happyid,stage)
    local uid = tt.owner:getUid() .. ""
    for i,history in ipairs(tt.game_data.xiazhu_bet_history[uid] or {}) do
        if history.happyid == happyid and history.stage == stage then
            return true
        end
    end
    return false
end

-- function NativeData.saveXiazhuLuckHistory(happyid,data)
--     tt.game_data.xiazhu_luck_history_happyid = happyid
--     tt.game_data.xiazhu_luck_history = data
--     save_data()
-- end

-- function NativeData.getXiazhuLuckHistoryHappyid()
--     return tt.game_data.xiazhu_luck_history_happyid or ""
-- end

-- function NativeData.getXiazhuLuckHistory()
--     return tt.game_data.xiazhu_luck_history or {}
-- end
local hallRecommendDatas
function NativeData.getHallRecommendDatas()
    return hallRecommendDatas or {
        {   gtype="cash",   --现金场
            rmd=0,  --整个现金场
        },
        {   
            gtype="mtt",   --mtt场次
            rmd=0,  --整个mtt场次
        },
    }
end

function NativeData.setHallRecommendDatas(datas)
    hallRecommendDatas = datas
end

local vp_config = {}
function NativeData.setVpConfig(config)
    vp_config = checktable(config)
end

function NativeData.getVpExpConfig()
    return vp_config.vp or {}
end

function NativeData.getVpPayConfig()
    return vp_config.vp_pay or {}
end

function NativeData.getVpExchangeConfig()
    return vp_config.vp_exchange or {}
end

function NativeData.getVpLoginConfig()
    return vp_config.login_vp or {}
end

function NativeData.getHornMsgHistory()
    return tt.game_data.horn_history
end

function NativeData.addHornMsg(mtype,uid,name,content,time)
    local save = {
        mtype = mtype,
        uid = uid,
        name = name,
        content = content,
        time = time,
    }
    table.insert(tt.game_data.horn_history,save)
    if #tt.game_data.horn_history > 50 then
        table.remove(tt.game_data.horn_history,1)
    end
    save_data()
end

function NativeData.savePicsVersion(version)
    tt.game_data.pics_version = version
    save_data()
end

function NativeData.getPicsVersion()
    return tt.game_data.pics_version or 0
end

function NativeData.saveCustomConfig(config)
    tt.game_data.custom_config = checktable(config)
    save_data()
end

function NativeData.getCustomConfig()
    return tt.game_data.custom_config or {}
end

function NativeData.saveCustomOperation(operation)
    tt.game_data.custom_operation = checktable(operation)
    save_data()
end

function NativeData.getCustomOperation()
    return tt.game_data.custom_operation or {}
end

return NativeData