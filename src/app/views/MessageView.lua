local MessageView = class("MessageView", function()
	return display.newNode()
end)


function MessageView:ctor(control)
	self.control_ = control 
	local node, width, height = cc.uiloader:load("message_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentView = cc.uiloader:seekNodeByName(node, "content_view")
	self.mBg = cc.uiloader:seekNodeByName(node, "background")
	self.mLabel = cc.uiloader:seekNodeByName(node, "label")
    self.mLabel:setLineHeight(60)
	self.mLabel2 = cc.uiloader:seekNodeByName(node, "label2")
    self.mLabel2:setLineHeight(60)
	self.mSureBtn = cc.uiloader:seekNodeByName(node, "sure_btn")
end

function MessageView:show(str,func)
    -- str = "khsfjkshjfkhsjfhjkshdkf h sjkhfjksndjkfsh  sjkhgkdhj kns jkshgj js jkshgj khsfjkshjfkhsjfhjkshdkf h"
	bg = self.mBg
    local msize = cc.size(1200,100)--bg:getContentSize()
    local bgPosX,bgPosY = bg:getPosition()
    local label
    local t_pos_x
    if func then
    	self.mLabel:setVisible(false)
    	self.mLabel2:setVisible(true)
    	self.mSureBtn:setVisible(true)
    	t_pos_x = 490
    	label = self.mLabel2
    	self.mSureBtn:onButtonClicked(function()
				tt.play.play_sound("click")
    			func()
    			self:dismiss()
    		end)
    else
    	self.mLabel:setVisible(true)
    	self.mLabel2:setVisible(false)
    	self.mSureBtn:setVisible(false)
    	t_pos_x = 640
    	label = self.mLabel
    end
    label:setString(tostring(str))

    local txtSize = label:getContentSize()
    local h = math.max(txtSize.height + 40,msize.height)
    local scale = h/msize.height
    bg:setContentSize(cc.size(msize.width,h))
    label:setPosition(t_pos_x ,bgPosY-h/2+0*scale+12)
    self.mSureBtn:setPositionY(bgPosY-h/2+0*scale)

    local top = display.cy + 360
    self.mContentView:setPosition(0,h)
    local sequence = transition.sequence({
        cc.MoveTo:create(0.5, cc.p(0,0)),
        cc.DelayTime:create(5),
        cc.MoveTo:create(0.5, cc.p(0,h)),
        -- cc.FadeOut:create(1),
        cc.CallFunc:create(function() self:dismiss() end)

    })
    sequence:setTag(1)
    bg:setTouchEnabled(true)
    bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            local name, x, y = event.name, event.x, event.y
            -- print('--------------')
            if name == "ended" then
                self.mContentView:stopActionByTag(1)
                bg:setTouchEnabled(false)
                local x,y = self.mContentView:getPosition()
                -- print(x,y)
                local factor = math.abs(1 - y / h)
                -- print(0.5*factor)
                local sequence = transition.sequence({
                    cc.MoveTo:create(0.5*factor, cc.p(0, h)),
                    -- cc.FadeOut:create(1),
                    cc.CallFunc:create(function() self:dismiss() end)
                })
                sequence:setTag(1)
                self.mContentView:runAction(sequence)
            end
            return true
        end)

    self.mContentView:setCascadeOpacityEnabled(true)
    self.mContentView:runAction(sequence)
end

function MessageView:dismiss()
	self:removeSelf()
end

return MessageView