local StaticEvent = {}


local function onNativeEvent(evt)
	if evt.cmd == tt.platformEventHalper.callbackCmds.gpayConsume then 
		tt.show_msg(tt.gettext("支付成功筹码到賬中..."))
		local params = json.decode(evt.params)
		params.pmode = 1
		tt.nativeData.saveRequestShipData(params)
		tt.ghttp.request(tt.cmd.gconsume,params)
	elseif evt.cmd == tt.platformEventHalper.callbackCmds.payCallback then
		local params = json.decode(evt.params)
		if params.ret == 1 then
            params.pmode = 2
			tt.nativeData.saveRequestShipData(params)
			tt.ghttp.request(tt.cmd.ivalidate,params)
			tt.show_msg(tt.gettext("支付成功筹码到賬中..."))
	 	elseif params.ret == 2 then
	 		-- 支付取消
	 	elseif params.ret == 3 then
	 		-- 支付失敗
		end
	elseif evt.cmd == tt.platformEventHalper.callbackCmds.bluepayCallback then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			tt.show_msg(tt.gettext("支付成功筹码到賬中..."))
	 	elseif params.ret == 2 then
	 		-- 支付取消
	 	elseif params.ret == 3 then
	 		-- 支付失敗
		end
	elseif evt.cmd == tt.platformEventHalper.callbackCmds.shareCallback then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			tt.gsocket.request("reward.getreward",{mtype = "share"})
	 	elseif params.ret == 2 then
	 	elseif params.ret == 3 then
		end
	elseif evt.cmd == tt.platformEventHalper.callbackCmds.FBGetAllRequestsForReward then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			tt.gsocket.request("reward.write_invite",{mtype = "fb",code=params.mid})
	 	elseif params.ret == 2 then
	 	elseif params.ret == 3 then
		end
	end
end

local function onSocketData(evt)
	print("StaticEvent onSocketData",evt.cmd)
	if evt.cmd == "sng.mlv_info" then
		if evt.resp then
			local resp = evt.resp
			if resp.ret == 200 then
				tt.nativeData.updateLvSngInfo(resp.mlv,resp.info)
			end
		end
	elseif evt.cmd == "info.ver" then 
		if evt.resp then
			if evt.resp.ret == 200 then 
				local info = evt.resp
				-- if not tt.game_data.shop_ver or tt.game_data.shop_ver ~= info.ver.shop then 
				-- 	tt.gsocket.request("shop.getshops",{chan=kChan})
				-- end
				
				if not tt.game_data.cash_info or tt.game_data.cash_info_ver ~= info.ver.cash then 
					tt.gsocket.request("alloc.info",{chan=kChan})
				end

				if not tt.game_data.sng_info or tt.game_data.sng_info_ver ~= info.ver.sng then 
			    	tt.gsocket.request("sng.info",{mtype=1,chan=kChan})
				end

				if not tt.game_data.vip_info or tt.game_data.vip_info_ver ~= info.ver.vip then
					tt.gsocket.request("vip.getlvinfo",{chan=kChan})
				else
					tt.gsocket.request("vip.vip_info",{mid=tt.owner:getUid()})
				end

			else
	    		tt.show_msg(tt.gettext("獲取版本信息失敗" ))
			end
		elseif evt.broadcast then
    		tt.gsocket.request("info.ver",{chan=kChan})
		end
	-- elseif evt.cmd == "shop.getshops" then 
	-- 	if evt.resp and evt.resp.ret == 200 then 
	-- 		local info = evt.resp
	-- 		tt.nativeData.saveShopInfo(info.ver,info.shops)
	-- 	end
	elseif evt.cmd == "alloc.info" then 
		if evt.resp and evt.resp.ret == 200 then
			tt.nativeData.saveCashInfo(evt.resp.ver,evt.resp.levels)
		end
	elseif evt.cmd == "sng.info" then 
		-- 更新自己的比賽狀態
		if evt.resp and evt.resp.ret == 200 then
			tt.nativeData.saveSngInfo(evt.resp.ver,evt.resp.levels)
		end
	elseif evt.cmd == "mtt.match_info" then
		if evt.resp.ret == 200 then
			tt.nativeData.saveMttInfo(evt.resp.match_id,evt.resp.info)
		end
	elseif evt.cmd == "vip.getlvinfo" then
		if evt.resp and evt.resp.ret == 200 then
			dump(evt.resp,"vip.getlvinfo")
			tt.nativeData.saveVipInfo(evt.resp.ver,evt.resp.info)
			tt.gsocket.request("vip.vip_info",{mid=tt.owner:getUid()})
		end
	elseif evt.cmd == "vip.vip_info" then
		if evt.resp and evt.resp.ret == 200 then
			dump(evt.resp,"vip.vip_info")
			tt.owner:setVipLv(evt.resp.lv)
			tt.owner:setVipOLv(evt.resp.olv)
			tt.owner:setVipExp(evt.resp.exp)
			tt.owner:setVipScore(evt.resp.score)
		end
		if evt.broadcast then
			dump(evt.broadcast,"vip.vip_info")
			tt.owner:setVipExp(evt.broadcast.total_exp)
			tt.owner:setVipScore(evt.broadcast.total_score)
		end
	elseif evt.cmd == "texas.intexp" then
		if evt.resp and evt.resp.ret == 200 then
			tt.owner:setMoney(evt.resp.left)
		end
	elseif evt.cmd == "richdata.getprop" then
		if evt.resp and evt.resp.ret == 200 then
			local num = evt.resp.prop[11] or evt.resp.prop["11"]
			if num then
				tt.owner:setJuan(num)
			end
			local num = evt.resp.prop[12] or evt.resp.prop["12"]
			if num then
				tt.owner:setHorn(num)
			end
		end
	elseif evt.cmd == "mtt.apply" then
		if evt.resp.ret == 200 then 
			local fee = evt.resp.fee
			if fee.etype == 1 then
				tt.owner:setMoney(fee.left)
			elseif fee.etype == 2 then
				tt.owner:setVipScore(fee.left)
			elseif fee.etype == 11 then
				tt.owner:setJuan(fee.left)
			end
		end
	elseif evt.cmd == "mtt.cancel" then 
		if evt.resp.ret == 200 or evt.resp.ret == 201 then 
			local fee = evt.resp.fee
			if fee.etype == 1 then
				tt.owner:setMoney(fee.left)
			elseif fee.etype == 2 then
				tt.owner:setVipScore(fee.left)
			elseif fee.etype == 11 then
				tt.owner:setJuan(fee.left)
			end
		end
	elseif evt.cmd == "msgbox.pushmsg" then
		dump(evt)
		if evt.broadcast then
			dump(evt.broadcast)
			if evt.broadcast.mtype == 1001 then
				local data = json.decode(evt.broadcast.msg)
				if data then 
					tt.owner:setMoney(data.total_glod)
				end
			elseif evt.broadcast.mtype == 1003 then
				local data = json.decode(evt.broadcast.msg)
				if data then
					if data.money then
						tt.owner:setMoney(checkint(data.money))
					end

					if data.score then
						tt.owner:setVipScore(checkint(data.score))
					end

					if data.gold then
						tt.owner:setCoins(checkint(data.gold))
					end

					if data.vp then
						tt.owner:setVpExp(checkint(data.vp))
					end

					if data.horn then
						tt.owner:setHorn(checkint(data.horn))
					end

					if data.is_pay then
						tt.owner:setFirstPay(checkint(data.is_pay)~=1)
					end
				end
			end
			local data = tt.nativeData.getFirstRecharge()
			if data then
				tt.ghttp.request(tt.cmd.firstshop,{})
			end
		end
	elseif evt.cmd == "happydice.show_table" then
		if evt.resp then
			tt.nativeData.saveXiazhuFactor(evt.resp.ver,evt.resp.show)
			tt.nativeData.saveXiazhuMinLeft(evt.resp.min_left)
			tt.nativeData.saveXiazhuMinUnit(evt.resp.min_unit)
		end
	elseif evt.cmd == "happydice.money2gold" then
		if evt.resp and evt.resp.ret == 200 then
			tt.owner:setMoney(evt.resp.left_money)
			tt.owner:setCoins(evt.resp.left_gold)
		end
	elseif evt.cmd == "happydice.bet" then
		if evt.resp and evt.resp.ret == 200 then
			tt.owner:setCoins(evt.resp.left_gold)

			tt.nativeData.saveXiaZhuBetHistory({
					time = tt.time(),
					stage = evt.resp.stage,
					happyid = evt.resp.happyid,
					bets = evt.resp.bets,
				})
		end
	elseif evt.cmd == "happydice.open_stage" then
		if evt.resp then
		 	if evt.resp.ret == 200 then
		 		tt.nativeData.updateXiaZhuBetHistoryByLuck(evt.resp.happyid,evt.resp.stage,evt.resp.luck_num)
		 		tt.owner:setVipScore(evt.resp.tscore) 
		 	elseif evt.resp.ret == -101 then
		 		tt.nativeData.clearXiaZhuBetHistory(evt.resp.happyid,evt.resp.stage)
		 	end
		elseif evt.broadcast then
			if tt.nativeData.checkXiazhuBetHistory(evt.broadcast.happyid,evt.broadcast.stage) then
				tt.gsocket.request("happydice.open_stage",{
						mid = tt.owner:getUid(),
						happyid = evt.broadcast.happyid,
						stage = evt.broadcast.stage,
					})
			end
		end
	elseif evt.cmd == "uinfo.ginfo" then
		if evt.resp then
		 	if evt.resp.ret == 200 then
				tt.owner:setMoney(evt.resp.money)
				tt.owner:setVipScore(evt.resp.score)
				tt.owner:setCoins(evt.resp.gold)
		 	end
		end

	elseif evt.cmd == "game.rmdlvs" then
		if evt.resp then
		 	if evt.resp.ret == 200 then
		 		tt.nativeData.setHallRecommendDatas(evt.resp.info)
		 	elseif evt.resp.ret == -101 then
		 		tt.nativeData.setHallRecommendDatas()
		 	end
		elseif evt.broadcast then
			tt.gsocket.request("game.rmdlvs",{mid=tt.owner:getUid()})
		end
	elseif evt.cmd == "game.gift_money" then
		if evt.resp then
		 	if evt.resp.ret == 200 then
		 		tt.owner:setMoney(evt.resp.left_money)
		 	end
		elseif evt.broadcast then
	 		tt.owner:setMoney(evt.broadcast.tmoney)
		end
	elseif evt.cmd == "msgbox.live_broad" then
		if evt.resp then
			if evt.resp.ret == 200 then
				tt.owner:setHorn(evt.resp.left)
			end
		end
		if evt.broadcast then
			if evt.broadcast.mtype == "bar" then
				tt.nativeData.addHornMsg(evt.broadcast.mtype,evt.broadcast.sender,"",evt.broadcast.content,evt.broadcast.stime)
			elseif evt.broadcast.mtype == "user_bar" then
				local data = json.decode(evt.broadcast.content)
				tt.nativeData.addHornMsg(evt.broadcast.mtype,evt.broadcast.sender,data.name,data.content,evt.broadcast.stime)
			elseif evt.broadcast.mtype == "custom_bugle" then
				local data = json.decode(evt.broadcast.content)
				tt.nativeData.addHornMsg(evt.broadcast.mtype,evt.broadcast.sender,"",evt.broadcast.content,evt.broadcast.stime)
			end
		end
	elseif evt.cmd == "reward.info" then
		if evt.resp then
			tt.owner:setFreeRewardData(evt.resp)
		end
	elseif evt.cmd == "reward.getreward" then
		if evt.resp then
			if evt.resp.ret == 200 then
				if evt.resp.mtype == "share" then
					tt.owner:setMoney(evt.resp.tmoney)
				end
			end
		end
		if evt.broadcast then
			if evt.broadcast.mtype == "invite" then
				tt.owner:setMoney(evt.broadcast.tmoney)
				tt.show_msg(tt.gettext("奖励 {s1}筹码 已到账",evt.broadcast.tmoney))
			elseif evt.broadcast.mtype == "invited" then
				tt.owner:setMoney(evt.broadcast.tmoney)
				tt.show_msg(tt.gettext("奖励 {s1}筹码 已到账",evt.broadcast.tmoney))
			elseif evt.broadcast.mtype == "invite_fb" then
				tt.owner:setMoney(evt.broadcast.tmoney)
				tt.show_msg(tt.gettext("奖励 {s1}筹码 已到账",evt.broadcast.tmoney))
			end
		end
	elseif evt.cmd == "reward.write_invite" then
		if evt.resp then 
			if evt.resp.ret == 200 then
        		tt.owner:setInviteid(evt.resp.inviteid)
			else
			end
		end
	elseif evt.cmd == "custom.config" then
		if evt.resp then
			if evt.resp.ret == 200 then
				tt.nativeData.saveCustomConfig(evt.resp.info)
			end
		end
	elseif evt.cmd == "custom.create_room" then
		if evt.resp then
			if evt.resp.ret == 200 then
				if evt.resp.left_money then
					tt.owner:setMoney(evt.resp.left_money)
				end
			end
		end
	elseif evt.cmd == "custom.show_status" then
		if evt.resp then
			if evt.resp.ret == 200 then
				if evt.resp.left_money then
					tt.owner:setMoney(evt.resp.left_money)
				end
			end
		end
	elseif evt.cmd == "custom.owner_reward" then
		if evt.broadcast then
			if evt.broadcast.ownerid == tt.owner:getUid() then
				if evt.broadcast.left_money then
					tt.owner:setMoney(evt.broadcast.left_money)
				end
			end
		end
	end
end

local function onHttpResp(evt)
	if evt.cmd == tt.cmd.getshops then
		dump(evt,"getshops")
		if evt.data.ret == 0 then
			local data = evt.data.data
			tt.nativeData.saveShopInfo(0,data)
			tt.owner:setFirstPay(data[1] and data[1].is_first == 1)
		elseif evt.data.ret == 5 then
			tt.nativeData.saveShopInfo(0,{})
		end
	elseif evt.cmd == tt.cmd.order then 
		dump(evt.data,"order")
		if evt.data.ret == 0 then
			local data = evt.data.data
			if data.pmode == 1 then
				local pinfo = data.pinfo
				local params = clone(tt.platformEventHalper.cmds.GPayLuaCall)
			    params.args = {
			        sku=pinfo.sku,
			        orderid=data.orderid,
			    }
			    dump(params,"GPayLuaCall")
			    local ret,error = tt.platformEventHalper.callEvent(params)
			    if not ret then
					tt.show_msg(error)
					tt.play.play_sound("action_failed")
				end
			elseif data.pmode == 2 then
				-- dump(evt.resp)
				local pinfo = data.pinfo
				local params = clone(tt.platformEventHalper.cmds.storekit)
				params.args.productID = pinfo.productID
				params.args.pid = data.pid
				params.args.orderid = data.orderid
				params.args.pmode = data.pmode .. "" -- ios 传int 低版本可能会出错
				local ret,error = tt.platformEventHalper.callEvent(params)
				if not ret then
					tt.show_msg(error)
					tt.play.play_sound("action_failed")
				end
			elseif data.pmode == 3 then
				local pinfo = data.pinfo
				local price = tonumber(pinfo.price)
				if kHttpUrl2 == "http://thailand.haoyun51.com/" or kHttpUrl2 == "http://thailand.woyaohaoyun.com/" then
					price = price * 100
				end
			    if device.platform == "android" then
					local params = clone(tt.platformEventHalper.cmds.bluepay_payBySMS)
				    params.args = {
				    	propsName=pinfo.propsName,
				    	smsId=0,
				        price=price,
				        transactionId=data.orderid,
				    }
				    dump(params,"bluepay_payBySMS")
				    local ret,error = tt.platformEventHalper.callEvent(params)
				    if not ret then
						tt.show_msg(error)
						tt.play.play_sound("action_failed")
					end
			    else
			    	local url = string.format("%sbluepay/index.php?productId=%d&transactionId=%s&price=%d",kBluePayUrl,kBluePayProductId,data.orderid,price)
			    	device.openURL(url)
			 	end
			elseif data.pmode == 4 then
				if device.platform == "android" then
					local pinfo = data.pinfo
					local params = clone(tt.platformEventHalper.cmds.bluepay_payByCashcard)
				    params.args = {
				    	userID=tt.owner:getUid(),
				    	propsName=pinfo.propsName,
				        publisherCode="bluecoins",
				        transactionId=data.orderid,
				    }
				    dump(params,"bluepay_payByCashcard")
			    	local ret,error = tt.platformEventHalper.callEvent(params)
			    	if not ret then
						tt.show_msg(error)
						tt.play.play_sound("action_failed")
					end
			    else
			    	local url = string.format("%sbluepay/cashcard/?productId=%d&transactionId=%s&provider=%s",kBluePayUrl,kBluePayProductId,data.orderid,"bluecoins")
			    	device.openURL(url)
			 	end
			elseif data.pmode == 5 then
				if device.platform == "android" then
					local pinfo = data.pinfo
					local params = clone(tt.platformEventHalper.cmds.bluepay_payByCashcard)
				    params.args = {
				    	userID=tt.owner:getUid(),
				    	propsName=pinfo.propsName,
				        publisherCode="dtac",
				        transactionId=data.orderid,
				    }
				    dump(params,"bluepay_payByCashcard")
			    	local ret,error = tt.platformEventHalper.callEvent(params)
			    	if not ret then
						tt.show_msg(error)
						tt.play.play_sound("action_failed")
					end
			    else
			    	local url = string.format("%sbluepay/cashcard/?productId=%d&transactionId=%s&provider=%s",kBluePayUrl,kBluePayProductId,data.orderid,"dtac")
			    	device.openURL(url)
			 	end
			elseif data.pmode == 6 then
				if device.platform == "android" then
					local pinfo = data.pinfo
					local params = clone(tt.platformEventHalper.cmds.bluepay_payByCashcard)
				    params.args = {
				    	userID=tt.owner:getUid(),
				    	propsName=pinfo.propsName,
				        publisherCode="truemoney",
				        transactionId=data.orderid,
				    }
				    dump(params,"bluepay_payByCashcard")
			    	local ret,error = tt.platformEventHalper.callEvent(params)
			    	if not ret then
						tt.show_msg(error)
						tt.play.play_sound("action_failed")
					end
			    else
			    	local url = string.format("%sbluepay/cashcard/?productId=%d&transactionId=%s&provider=%s",kBluePayUrl,kBluePayProductId,data.orderid,"truemoney")
			    	device.openURL(url)
			 	end
			elseif data.pmode == 7 then
				if device.platform == "android" then
					local pinfo = data.pinfo
					local params = clone(tt.platformEventHalper.cmds.bluepay_payByCashcard)
				    params.args = {
				    	userID=tt.owner:getUid(),
				    	propsName=pinfo.propsName,
				        publisherCode="12call",
				        transactionId=data.orderid,
				    }
				    dump(params,"bluepay_payByCashcard")
			    	local ret,error = tt.platformEventHalper.callEvent(params)
			    	if not ret then
						tt.show_msg(error)
						tt.play.play_sound("action_failed")
					end
			    else
			    	local url = string.format("%sbluepay/cashcard/?productId=%d&transactionId=%s&provider=%s",kBluePayUrl,kBluePayProductId,data.orderid,"12call")
			    	device.openURL(url)
			 	end
			elseif data.pmode == 8 then
				if device.platform == "android" then
					local pinfo = data.pinfo
					local params = clone(tt.platformEventHalper.cmds.bluepay_payByWallet)
					local price = tonumber(pinfo.price)
					if kHttpUrl2 == "http://thailand.haoyun51.com/" or kHttpUrl2 == "http://thailand.woyaohaoyun.com/" then
						price = price * 100
					end
				    params.args = {
				    	userID=tt.owner:getUid(),
				    	propsName=pinfo.propsName,
				        price=price,
				        transactionId=data.orderid,
				    }
				    dump(params,"bluepay_payByWallet")
				    local ret,error = tt.platformEventHalper.callEvent(params)
			    	if not ret then
						tt.show_msg(error)
						tt.play.play_sound("action_failed")
					end
			    else
			 	end
			end
		end
	elseif evt.cmd == tt.cmd.gconsume then 
		if evt.data.ret == 0 then 

			local data = evt.data.data

			tt.show_msg(tt.gettext("筹码到账"))
			-- tt.show_msg(json.encode(evt.resp) )

			if data.money then
				tt.owner:setMoney(checkint(data.money))
			end

			if data.score then
				tt.owner:setVipScore(checkint(data.score))
			end

			if data.gold then
				tt.owner:setCoins(checkint(data.gold))
			end

			if data.vp then
				tt.owner:setVpExp(checkint(data.vp))
			end

			if data.rich_num then
				tt.owner:setHorn(checkint(data.rich_num))
			end

			tt.owner:setFirstPay(false)

			tt.nativeData.clearRequestShipData(data.orderid)

			local data = tt.nativeData.getFirstRecharge()
			if data then
				tt.ghttp.request(tt.cmd.firstshop,{})
			end
		elseif evt.data.ret == 15 then
			local data = evt.data.data
			tt.nativeData.clearRequestShipData(data.orderid)
			tt.owner:setFirstPay(false)
		else
    		tt.show_msg(tt.gettext("支付獲取筹码失敗,請與客服聯係") )
		end
	elseif evt.cmd == tt.cmd.ivalidate then 
		if evt.data.ret == 0 then 
			local data = evt.data.data

			tt.show_msg(tt.gettext("筹码到账"))
			if data.money then
				tt.owner:setMoney(checkint(data.money))
			end

			if data.score then
				tt.owner:setVipScore(checkint(data.score))
			end

			if data.gold then
				tt.owner:setCoins(checkint(data.gold))
			end

			if data.vp then
				tt.owner:setVpExp(checkint(data.vp))
			end

			if data.rich_num then
				tt.owner:setHorn(checkint(data.rich_num))
			end

			tt.owner:setFirstPay(false)

			tt.nativeData.clearRequestShipData(data.orderid)
			
			local data = tt.nativeData.getFirstRecharge()
			if data then
				tt.ghttp.request(tt.cmd.firstshop,{})
			end
		elseif evt.data.ret == 15 then
			local data = evt.data.data
			tt.nativeData.clearRequestShipData(data.orderid)
			tt.owner:setFirstPay(false)
		else
    		-- tt.show_msg("支付獲取筹码失敗,請與客服聯係" )
		end
	elseif evt.cmd == tt.cmd.selectShop then
		local data = evt.data
		if data then
			if data.ret == 0 then
				local params = data.data
				for i,propData in ipairs(params) do
					tt.nativeData.savePropData(propData.pid,propData)
				end
			end
		end
	elseif evt.cmd == tt.cmd.switch_shop then
		if evt.data.ret == 0 then
			tt.nativeData.setVipShopLock(tonumber(evt.data.data.is_shop) == 0)
		end
	elseif evt.cmd == tt.cmd.firstshop then
		if evt.data then
			if evt.data.ret == 0 then
				tt.nativeData.setFirstRecharge(evt.data.data)
			elseif evt.data.ret == 101 then
				tt.nativeData.setFirstRecharge()
			end
		end
	elseif evt.cmd == tt.cmd.everyday_list then
		if evt.data then
			if evt.data.ret == 0 then
				tt.nativeData.setEverydayList(evt.data.data)
			end
		end
	elseif evt.cmd == tt.cmd.everyday_login then
		if evt.data then
			if evt.data.ret == 0 then
				tt.owner:setMoney(evt.data.data.left)
				tt.owner:setCoins(evt.data.data.left_gold)
			end
		end
	elseif evt.cmd == tt.cmd.vp_club then
		if evt.data then
			if evt.data.ret == 0 then
				local data = evt.data.data
				tt.owner:setVpLv(data.levelinfo.leveling)
				tt.owner:setVpExp(data.levelinfo.vping)
				tt.nativeData.setVpConfig(data)
			end
		end
	end
end

function onShakeOK()
    tt.gsocket.request("info.ver",{chan=kChan})
    local data = tt.nativeData.getFirstRecharge()
	if data then
		tt.ghttp.request(tt.cmd.firstshop,{})
	end
    local data = tt.nativeData.getEverydayList()
	if not data then
		tt.ghttp.request(tt.cmd.everyday_list,{})
	end
	tt.ghttp.request(tt.cmd.vp_club,{})
	tt.ghttp.request(tt.cmd.getshops,{})

    tt.gsocket.request("uinfo.ginfo",{mid=tt.owner:getUid()})
    tt.gsocket.request("game.rmdlvs",{mid=tt.owner:getUid()})
	tt.gsocket.request("richdata.getprop",{mid=tt.owner:getUid()})
	tt.gsocket.request("reward.info",{})

	local config = tt.nativeData.getCustomConfig()
		tt.gsocket.request("custom.config",{
				ver = config.ver or 0,
			})
end

function StaticEvent.init()
	tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT,onNativeEvent)
	tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, onSocketData)
	tt.gevt:addEventListener(tt.gevt.EVT_HTTP_RESP, onHttpResp)
	tt.gevt:addEventListener(tt.gevt.SHAKE_OK, onShakeOK)

end

return StaticEvent
