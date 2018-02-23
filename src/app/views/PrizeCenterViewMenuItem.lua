--
-- Author: shineflag
-- Date: 2017-05-19 17:36:13
--


local PrizeCenterViewMenuItem = class("PrizeCenterViewMenuItem", function()
	return display.newNode()
end)


function PrizeCenterViewMenuItem:ctor(ctl, index,data)
	self.ctl_ = ctl 
	local node, width, height = cc.uiloader:load("prize_center_menu_item.json")
	--find view by layout
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mSelectIcon = cc.uiloader:seekNodeByName(node, "select_icon")

	cc.uiloader:seekNodeByName(node, "txt"):setString(data.classify_name)

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
        	if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
	    	return true 
	    elseif event.name ~= "began" and down then
	    	if math.abs(startX-x) > 10 or math.abs(startY-y) > 10 then
	    		down = false
	    	end
	    	if event.name == "ended" then
				tt.play.play_sound("click")
				if type(self.choiceClickFunc) == "function" then
					self.choiceClickFunc(index,data)
				end
			end
		end
	end)
end

function PrizeCenterViewMenuItem:setSelected(flag)
	if flag then
		self.mSelectIcon:setTexture("dec/dec_selected.png")
	else
		self.mSelectIcon:setTexture("dec/dec_noselected.png")
	end
end

function PrizeCenterViewMenuItem:setOnChoiceClick(func)
	self.choiceClickFunc = func
end

return PrizeCenterViewMenuItem
