--
-- Author: shineflag
-- Date: 2017-02-15 11:00:59
--

local cmd = {
	bindtoken = "App/Poker/bindToken",
	vstore = "App/Shop/vstore", --库存列表
	exchange = "App/Shop/exchange", --商品兑换
	goods = "App/Shop/goods", --个人兑换的商品列表
	add_detail = "App/Shop/add_detail", --兑换后商品信息填写
	selectShop = "App/Shop/selectShop", --查询商品
	everyday_detail = "App/Poker/everyday_detail", --每天赠送详情
	user_break = "App/Poker/user_break",--是否破产查询
	everyday_song = "App/Poker/everyday_song",--获取赠送金币
	ver_check = "App/Poker/ver_check",--版本更新
	getshops = "App/Pay/getshops2",--获取套餐
	order = "App/Pay/order",--下单
	gconsume = "App/Pay/gconsume",--google支付成功，请求发货
	ivalidate = "App/Pay/ivalidate",--ios请求发货
	active_entrance = "App/Active/active_entrance",--活动入口请求
	switch_shop = "App/Poker/switch_shop",--商城开关
	firstshop = "App/Pay/firstshop",--首充
	everyday_login = "App/Poker/everyday_login",--领取每日奖励
	everyday_list = "App/Poker/everyday_list",--每天领取奖励列表
	loginTour = "App/Login/loginTour",--游客登录
	loginFB = "App/Login/loginFB",--fb登录
	vp_club = "App/Poker/vip_club",--vp配置
}

return cmd
