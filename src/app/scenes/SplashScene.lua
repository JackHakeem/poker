

local net = require("framework.cc.net.init")

local SplashScene = class("SplashScene", function()
    return display.newScene("SplashScene")
end)

function SplashScene:ctor()
	self:initView()
end

function SplashScene:initView() 
	local node, width, height = cc.uiloader:load("splash_scene.json")
	node:align(display.CENTER,display.cx,display.cy)
	self:addChild(node)
	self.root_ = node


	self.mPicsBg = cc.uiloader:seekNodeByName(node, "pics_bg"):setVisible(false)
	self.mPicsPage = cc.uiloader:seekNodeByName(node, "pics_page"):setVisible(false)
	self:init()
end

function SplashScene:onEnter()

	if device.platform == "ios" then
		self:checkShowPics()
	else
		self:performWithDelay(function()
				self:checkShowPics()
			end, 3)
	end
end

function SplashScene:checkShowPics()
	if tt.nativeData.getPicsVersion() == 2 then
		app:enterScene("LoginScene")
	else
		tt.nativeData.savePicsVersion(2)
		self:showPicsPage()
	end
end

function SplashScene:showPicsPage()
	self.mPicsBg:setVisible(true)
	self.mPicsPage:setVisible(true)

	for i=1,2 do
		local item = self.mPicsPage:newItem()
		local node = display.newNode()
		local sprite = display.newSprite(string.format("pics/pics_%d.png",i))
		node:addTo(item)
		node:setContentSize(cc.size(1280,720))
		sprite:addTo(node)

		if i == 2 then
			local btn = cc.ui.UIPushButton.new({
				normal = "btn/btn_etgame_nor.png",
				pressed = "btn/btn_etgame_pre.png",
				disabled = "btn/btn_etgame_pre.png",
			})

			btn:addTo(sprite)
			btn:onButtonClicked(function()
					tt.play.play_sound("click")
					app:enterScene("LoginScene")
				end)
			tt.LayoutUtil:layoutParentBottom(btn,0,100)
		end
		tt.LayoutUtil:layoutParentTop(sprite)
		tt.LayoutUtil:layoutParentCenter(node)
		self.mPicsPage:addItem(item)
	end

	self.mPicsPage:reload()
	local x = -40
	self.mPoints = {}
	for i=1,2 do
		self.mPoints[i] = display.newSprite("dec/ellipse_grey.png")
		self.mPoints[i]:addTo(self.root_)
		tt.LayoutUtil:layoutParentBottom(self.mPoints[i],x+(i-1)*50,20)
	end

	self.mPoints[1]:setTexture("dec/ellipse_blue.png")

	local arrow = display.newSprite("btn/arrow.png")
	
	arrow:addTo(self.root_)
	tt.LayoutUtil:layoutParentRight(arrow)
end

function SplashScene:init()
	function scroll(self,dis)
		local threePages = {}
		local count
		if self.pages_ then
			count = #self.pages_
		else
			count = 0
		end
		-- 第一个和最后一个禁止越界拉动
		local page = self.pages_[self.curPageIdx_]
		local posX, posY = page:getPosition()
		if page == self.pages_[#self.pages_] then
			if posX + dis < self.viewRect_.x then
				dis = self.viewRect_.x - posX
			end
		end

		if page == self.pages_[1] then
			if posX + dis > self.viewRect_.x then
				dis = self.viewRect_.x - posX
			end
		end

		local page
		if 0 == count then
			return
		elseif 1 == count then
			table.insert(threePages, false)
			table.insert(threePages, self.pages_[self.curPageIdx_])
		elseif 2 == count then
			local posX, posY = self.pages_[self.curPageIdx_]:getPosition()
			if posX > self.viewRect_.x then
				page = self:getNextPage(false)
				if not page then
					page = false
				end
				table.insert(threePages, page)
				table.insert(threePages, self.pages_[self.curPageIdx_])
			else
				table.insert(threePages, false)
				table.insert(threePages, self.pages_[self.curPageIdx_])
				table.insert(threePages, self:getNextPage(true))
			end
		else
			page = self:getNextPage(false)
			if not page then
				page = false
			end
			table.insert(threePages, page)
			table.insert(threePages, self.pages_[self.curPageIdx_])
			table.insert(threePages, self:getNextPage(true))
		end

		self:scrollLCRPages(threePages, dis)
	end

	function scrollAuto(self)
		local page = self.pages_[self.curPageIdx_]
		local pageL = self:getNextPage(false) -- self.pages_[self.curPageIdx_ - 1]
		local pageR = self:getNextPage(true) -- self.pages_[self.curPageIdx_ + 1]
		local bChange = false
		local posX, posY = page:getPosition()
		local dis = posX - self.viewRect_.x

		local pageRX = self.viewRect_.x + self.viewRect_.width
		local pageLX = self.viewRect_.x - self.viewRect_.width

		local count = #self.pages_
		if 0 == count then
			return
		elseif 1 == count then
			pageL = nil
			pageR = nil
		end
		if (dis > self.viewRect_.width/2 or self.speed > 10)
			and (self.curPageIdx_ > 1 or self.bCirc)
			and count > 1 then
			bChange = true
		elseif (-dis > self.viewRect_.width/2 or -self.speed > 10)
			and (self.curPageIdx_ < self:getPageCount() or self.bCirc)
			and count > 1 then
			bChange = true
		end

		if dis > 0 then
			if bChange then
				self.curPageIdx_ = self:getNextPageIndex(false)
				self:notifyListener_{name = "pageChange"}
				transition.moveTo(page,
					{x = pageRX, y = posY, time = 0.3,
					onComplete = function()
						self:disablePage()
					end})
				transition.moveTo(pageL,
					{x = self.viewRect_.x, y = posY, time = 0.3})
			else
				transition.moveTo(page,
					{x = self.viewRect_.x, y = posY, time = 0.3,
					onComplete = function()
						self:disablePage()
					end})
				if pageL then
					transition.moveTo(pageL,
						{x = pageLX, y = posY, time = 0.3})
				end
			end
		else
			if bChange then
				self.curPageIdx_ = self:getNextPageIndex(true)
				self:notifyListener_{name = "pageChange"}
				transition.moveTo(page,
					{x = pageLX, y = posY, time = 0.3,
					onComplete = function()
						self:disablePage()
					end})
				transition.moveTo(pageR,
					{x = self.viewRect_.x, y = posY, time = 0.3})
			else
				transition.moveTo(page,
					{x = self.viewRect_.x, y = posY, time = 0.3,
					onComplete = function()
						self:disablePage()
					end})
				if pageR then
					transition.moveTo(pageR,
						{x = pageRX, y = posY, time = 0.3})
				end
			end
		end
	end

	self.mPicsPage.scroll = scroll
	self.mPicsPage.scrollAuto = scrollAuto
	self.mPicsPage:onTouch(function(event)
			print("index",event.pageIdx)
			for i=1,4 do
				if not tolua.isnull(self.mPoints[i]) then
					if i ~= event.pageIdx then
						self.mPoints[i]:setTexture("dec/ellipse_grey.png")
					else
						self.mPoints[i]:setTexture("dec/ellipse_blue.png")
					end
				end
			end
		end)
end

return SplashScene
