local Emoticon = class("Emoticon", function(animCsb)
	return display.newNode()
end)

function Emoticon:ctor(animCsb)
	print("Emoticon",animCsb)
	self.mAnimView = cc.CSLoader:createNode(animCsb)
	self.mAction = cc.CSLoader:createTimeline(animCsb)
	self.mAnimView:runAction(self.mAction)
	self.mAnimView:addTo(self)
end

function Emoticon:play()
	self.mAction:gotoFrameAndPlay(0,true)
end

return Emoticon
