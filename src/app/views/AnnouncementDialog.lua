
local BLDialog = require("app.ui.BLDialog")
local TAG = "AnnouncementDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local AnnouncementDialog = class("AnnouncementDialog", function()
	return BLDialog.new()
end)


function AnnouncementDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("announcement_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.scroll_content = cc.uiloader:seekNodeByName(node,"scroll_content")
	self.content_txt = cc.uiloader:seekNodeByName(node,"content_txt")

	self.close_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.scroll_content:setBounceable(false)
end

function AnnouncementDialog:show(notice)
	BLDialog.show(self)
	if notice then 
		self:setContentString(notice)
	else
		tt.gsocket.request("msgbox.newnotice",{})
	end
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
	}
end

function AnnouncementDialog:setContentString(str)
	self.content_txt:setWidth(735)
	self.content_txt:setString(str)
end

function AnnouncementDialog:dismiss()
	BLDialog.dismiss(self)
	self:removeSelf()
end

function AnnouncementDialog:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end
	BLDialog.onExit(self)
end

function AnnouncementDialog:onSocketData(evt)
	tt.log.d(TAG, "cmd:[%s]",evt.cmd)	

	local resp = evt.resp
	if evt.cmd == "msgbox.newnotice" then
		-- req = {
		-- 	--空
		-- },
		-- resp = {
		-- 	ret = 200,   -- -101 还没有公告
		-- 	notice = {    --公告具体内容
		-- 		--  title = "xxx", --公告标题 
		-- 		--  content = "xxxx",  --公告内容
		--     }
		-- }
		if evt.resp.ret == 200 then
			self:setContentString(evt.resp.notice.content)
		end
	end
end


return AnnouncementDialog