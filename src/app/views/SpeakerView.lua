local TAG = "SpeakerView"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local SpeakerView = class("SpeakerView", function()
	return display.newNode()
end)


function SpeakerView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("speaker_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.root_:setCascadeOpacityEnabled(true)

	self.context_view = cc.uiloader:seekNodeByName(node,"context_view")
		:setCascadeOpacityEnabled(true)

	-- self.icon = cc.uiloader:seekNodeByName(node,"icon")
	-- 	:setCascadeOpacityEnabled(true)

	self.mMsgList = {}

	self.mMsgView = {}

	self:setOpacity(0)

	self:setCascadeOpacityEnabled(true)
end

function SpeakerView:addTouch()
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(false)
	local startX,startY =0,0
	local down = false
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
	    -- event.x, event.y 是触摸点当前位置
	    -- event.prevX, event.prevY 是触摸点之前的位置
	    -- printf("sprite: %s x,y: %0.2f, %0.2f",
	    --        event.name, event.x, event.y)

	    -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
	    -- 则必须返回 true
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	startX = x
        	startY = y
        	if not self.context_view:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
				tt.play.play_sound("click")
				self.control_:showSpeakerEditDialog()
			end
		end
	end)
end

function SpeakerView:show(str)
	printInfo("SpeakerView:show")
	-- self:setVisible(true)
	self:stopAction(self.mFadeAction)
	self.mFadeAction = transition.fadeIn(self, {time = 0.5})

	self:pushMsg(str)
	self:pushMsg(str)
	self:pushMsg(str)
	self:startAnim()
end

function SpeakerView:dismiss()
	printInfo("SpeakerView:dismiss")
	self:stopAction(self.mFadeAction)
	self.mFadeAction = transition.fadeTo(self, {time = 0.5,opacity=self.mOpacity})
	-- self:setVisible(false)
end

function SpeakerView:setDismissOpacity(opacity)
	self.mOpacity = opacity
	self:opacity(opacity)
end

function SpeakerView:startAnim()
	if self.mAnimDelay then return end
	local msg = table.remove(self.mMsgList,1)
	if msg then
		local label = display.newTTFLabel({
		    text = msg,
		    size = 36,
		    color = cc.c3b(0xa1, 0x5e, 0x32), -- 使用纯红色
		    align = cc.TEXT_ALIGNMENT_LEFT,
		    valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
		})
		label:addTo(self.context_view)
		local size = self.context_view:getContentSize()
		local tsize = label:getContentSize()
		local width = size.width + tsize.width
		local time = width / 60
		label:setPosition(size.width + tsize.width/2,20)
		transition.moveBy(label, {x = -width, y = 0, time = time})
		self.mAnimDelay = self:performWithDelay( function()
			self.mAnimDelay = nil
			self:startAnim()
		end ,tsize.width / 60 + 8)

		self:stopAction(self.mDismissAction)

		self.mDismissAction = self:performWithDelay( function()
			self.mDismissAction = nil
			self:dismiss()
		end ,time - 2)
	end
end

function SpeakerView:pushMsg(str)
	table.insert(self.mMsgList,str)
end

return SpeakerView