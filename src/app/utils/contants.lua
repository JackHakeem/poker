--
-- Author: shineflag
-- Date: 2017-04-23 17:52:51
--
--  所有常量

kAppid = 0
if device.platform == "ios" then
	kChan="appstore"
elseif device.platform == "android" then
	kChan="google"
elseif device.platform == "windows" then
	kChan="appstore"
else
	kChan="unknow"
end
kVersion = "1.5.0"

local dev = "http://10.0.0.111/"
local release = "http://thailand.haoyun51.com/"
local debug = "http://thailand.woyaohaoyun.com/"

kHttpUrl2 = release

kDownloadUrl = kHttpUrl2 .. "app/share/download"
kShareUrl = "http://d.haoyun51.com/ta/s/d"
kFacebackUrl = kHttpUrl2 .. "app/feedback/feedback"
kfbAppInviteUrl = kHttpUrl2 .. "app/share/invite_from_fb"
kfbAppInviteImgUrl = kHttpUrl2 .. "Public/app/share/invate.png"

kBluePayProductId = 1290
kBluePayUrl = "http://th.webpay.bluepay.tech/"

GAME_MODE_DEBUG = false

LANG = cc.FileUtils:getInstance():fullPathForFilename("res/zh.mo")

kSuccess = 1
kCancel  = 2
kFail    = 3
kTimeOut = 4

kCashRoom = 1
kSngRoom = 2
kMttRoom = 3
kCustomRoom = 4