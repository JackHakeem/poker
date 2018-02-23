--
-- Author: shineflag
-- Date: 2017-02-14 17:18:53
--
local clienttype
if device.platform == "android" then
    clienttype = 1
elseif device.platform == "ios" then
    clienttype = 2
elseif device.platform == "windows" then
    clienttype = 3
else
    clienttype = 0
end


local config = {
    os = clienttype,-- Android:1 iOS:2 
    mtkey = "",
    versions = kVersion,
    clienttype = clienttype,-- 系统类型1 android 2 android pad 3.ios 4.ios pad
}


return config