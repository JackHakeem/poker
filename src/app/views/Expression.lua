local Expression = class("Expression")

function Expression.createExpression(id,pos_src,pos_des)
	if Expression.id_map[id] then
		return Expression.id_map[id].new(pos_src,pos_des)
	end
end

local ExpressionRose = class("ExpressionRose", function()
	return display.newNode()
end)

function ExpressionRose:ctor(pos_src,pos_des)
	local animCsb = "expression/rose/rose.csb"
	print("Expression",animCsb)
	self.mPositions = {
		pos_src or cc.p(0,0),
		pos_des or cc.p(0,0),
	}

	self.mAnimView = cc.CSLoader:createNode(animCsb)
	self.mAction = cc.CSLoader:createTimeline(animCsb)
	self.mAnimView:runAction(self.mAction)
	self.mAnimView:addTo(self)

	if pos_src.x < pos_des.x then
		self.mAnimView:setScaleX(-1)
		self.mFlag = -1
	else
		self.mAnimView:setScaleX(1)
		self.mFlag = 1
	end
end

function ExpressionRose:getPlayTime()
	return 3
end

function ExpressionRose:play()
	tt.play.play_sound("rose")
	self.mAnimView:setPosition(self.mPositions[1])
	self.mAnimView:moveTo(0.6, self.mPositions[2].x-20*self.mFlag, self.mPositions[2].y+20)
	self.mAction:gotoFrameAndPlay(0,true)
end

local ExpressionCheers = class("ExpressionCheers", function()
	return display.newNode()
end)

function ExpressionCheers:ctor(pos_src,pos_des)
	local animCsb = "expression/cheers/cheers.csb"
	print("Expression",animCsb)
	self.mPositions = {
		pos_src or cc.p(0,0),
		pos_des or cc.p(0,0),
	}
	self.mAnimView = cc.CSLoader:createNode(animCsb)
	self.mAction = cc.CSLoader:createTimeline(animCsb)
	self.mAnimView:runAction(self.mAction)
	self.mAnimView:addTo(self)

	if pos_src.x < pos_des.x then
		self.mAnimView:setScaleX(-1)
		self.mFlag = -1
	else
		self.mAnimView:setScaleX(1)
		self.mFlag = 1
	end
end

function ExpressionCheers:getPlayTime()
	return 2.1
end

function ExpressionCheers:play()
	tt.play.play_sound("cheers")
	self.mAnimView:setPosition(self.mPositions[1])
	self.mAnimView:moveTo(0.5, self.mPositions[2].x, self.mPositions[2].y)
	self.mAction:gotoFrameAndPlay(0,true)
end

local ExpressionChicken = class("ExpressionChicken", function()
	return display.newNode()
end)

function ExpressionChicken:ctor(pos_src,pos_des)
	local animCsb = "expression/chicken/chicken.csb"
	print("Expression",animCsb)
	self.mPositions = {
		pos_src or cc.p(0,0),
		pos_des or cc.p(0,0),
	}
	self.mAnimView = cc.CSLoader:createNode(animCsb)
	self.mAction = cc.CSLoader:createTimeline(animCsb)
	self.mAnimView:runAction(self.mAction)
	self.mAnimView:addTo(self)

	self.mHand = display.newSprite("expression/chicken/hand.png")
	self.mHand:addTo(self)

	if pos_src.x < pos_des.x then
		self.mAnimView:setScaleX(-1)
		self.mHand:setScaleX(-1)
		self.mFlag = -1
	else
		self.mAnimView:setScaleX(1)
		self.mHand:setScaleX(1)
		self.mFlag = 1
	end
end

function ExpressionChicken:getPlayTime()
	return 3.3
end

function ExpressionChicken:play()
	tt.play.play_sound("chicken")
	self.mHand:setPosition(self.mPositions[1])
	self.mHand:moveTo(0.6, self.mPositions[2].x, self.mPositions[2].y+20)
	self.mHand:performWithDelay(function()
			self.mHand:setVisible(false)
		end, 0.6)
	self.mAnimView:setPosition(cc.p(self.mPositions[2].x, self.mPositions[2].y+20))
	self.mAction:gotoFrameAndPlay(0,true)
end

local ExpressionShark = class("ExpressionShark", function()
	return display.newNode()
end)

function ExpressionShark:ctor(pos_src,pos_des)
	self.mPositions = {
		pos_src or cc.p(0,0),
		pos_des or cc.p(0,0),
	}

	local animCsb = "expression/shark/fesh.csb"
	print("Expression",animCsb)
	self.mFishView = cc.CSLoader:createNode(animCsb)
	self.mFishAction = cc.CSLoader:createTimeline(animCsb)
	self.mFishView:runAction(self.mFishAction)
	self.mFishView:addTo(self)


	local animCsb = "expression/shark/shark.csb"
	print("Expression",animCsb)
	self.mSharkView = cc.CSLoader:createNode(animCsb)
	self.mSharkView:getChildByName("Sprite_1"):setTexture("expression/shark/shark01.png")
	self.mSharkAction = cc.CSLoader:createTimeline(animCsb)
	self.mSharkView:runAction(self.mSharkAction)
	self.mSharkView:addTo(self)

	if pos_src.x < pos_des.x then
		self.mSharkView:setScaleX(-1)
		self.mFishView:setScaleX(-1)
		self.mFlag = -1
	else
		self.mSharkView:setScaleX(1)
		self.mFishView:setScaleX(1)
		self.mFlag = 1
	end
end

function ExpressionShark:getPlayTime()
	return 3.4
end

function ExpressionShark:play()
	tt.play.play_sound("shark")
	local moveTime = 1.0
	local waitMove = 1.0

	self.mSharkView:setPosition(self.mPositions[1])
	self.mSharkView:performWithDelay(function()
			self.mSharkView:moveTo(moveTime, self.mPositions[2].x+50*self.mFlag, self.mPositions[2].y)
		end, waitMove)

	self.mSharkView:performWithDelay(function()
			self.mSharkAction:gotoFrameAndPlay(0,true)
		end, moveTime+waitMove)

	self.mFishView:setPosition(self.mPositions[2])
	self.mFishAction:gotoFrameAndPlay(0,true)
	self.mFishView:performWithDelay(function()
			self.mFishView:setVisible(false)
		end, 3)
end


Expression.id_map = {
	ExpressionRose,
	ExpressionCheers,
	ExpressionChicken,
	ExpressionShark,
}

return Expression
