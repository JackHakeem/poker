require("config")
require("cocos.init")
require("framework.init")
require "lfs"

local PokerApp = class("PokerApp", cc.mvc.AppBase)

function PokerApp:ctor()
    PokerApp.super.ctor(self)
end

function PokerApp:run()
	self:updateHotupdatePath()
    cc.Director:getInstance():setProjection(1)  --3D投射
    local writePath = cc.FileUtils:getInstance():getWritablePath() 
	cc.FileUtils:getInstance():addSearchPath("res/",true)
	cc.FileUtils:getInstance():addSearchPath(writePath .. "hotupdate/".. kPlatformVersionCode .. "/",true)
	cc.FileUtils:getInstance():addSearchPath(writePath .. "hotupdate/".. kPlatformVersionCode .. "/res/",true)
	dump(cc.FileUtils:getInstance():getSearchPaths(),"SearchPaths")
	if tt then
		tt.clearAll()
	end
	if device.model == "iphone" and jit.arch == "arm64" then
		cc.LuaLoadChunksFromZIP("game64.zip")
	else
		cc.LuaLoadChunksFromZIP("game.zip")
	end
	require("app.init")
	cc.FileUtils:getInstance():purgeCachedEntries()
	display.DEFAULT_TTF_FONT        = "woyao"
	if device.platform == "android" then
    	self:enterScene("SplashScene")
		tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.removeSplashView)
	else
    	self:enterScene("SplashScene")
	end
end

function PokerApp:onEnterBackground()
	print("PokerApp:onEnterBackground")
	PokerApp.super.onEnterBackground(self)
	-- tt.play.pause_music()
	-- tt.play.set_sounds_vol(0)
end

function PokerApp:onEnterForeground()
	print("PokerApp:onEnterForeground")
	PokerApp.super.onEnterForeground(self)
	-- tt.play.resume_music()
	-- tt.play.set_sounds_vol(1)
end

function PokerApp:updateHotupdatePath()
	--热更新目录
	kPlatformVersionCode = 1
	if device.platform == "android" then
		local ok,ret = luaj.callStaticMethod("com/woyao/luaevent/LuaEventProxy", "getVersionCode",{},"()I")
		print("kPlatformVersionCode",ok,ret)
		if ok then
			kPlatformVersionCode = ret
		end
	elseif device.platform == "ios" then
	    local ok,ret = luaoc.callStaticMethod("LuaEventProxy", "getVersionCode")
	    print("kPlatformVersionCode",ok,ret)
		if ok then
			kPlatformVersionCode = ret
		end
	end

	local function rmdir(path)
	    print("os.rmdir:", path)
	    if io.exists(path) then
    		print("os.rmdir start:", path)
	        local function _rmdir(path)
	            local iter, dir_obj = lfs.dir(path)
	            while true do
	                local dir = iter(dir_obj)
	                if dir == nil then break end
	                if dir ~= "." and dir ~= ".." then
	                    local curDir = path..dir
	                    -- print("os.rmdir",curDir)
	                    local mode = lfs.attributes(curDir, "mode") 
	                    if mode == "directory" then
	                        _rmdir(curDir.."/")
	                    elseif mode == "file" then
	                        os.remove(curDir)
	                    end
	                end
	            end
	            local succ, des = os.remove(path)
	            if des then print(des) end
	            return succ
	        end
	        _rmdir(path)
	    end
	    return true
	end

	print("kPlatformVersionCode",kPlatformVersionCode)
    local writePath = cc.FileUtils:getInstance():getWritablePath() .. "hotupdate/"
    if io.exists(writePath) then
		for file in lfs.dir(writePath) do
			if file ~= "." and file ~= ".." then
		    	print("kPlatformVersionCode path",file)
		        local f = writePath .. file
		        local attr = lfs.attributes(f)
		        if attr.mode == "directory" and file ~= kPlatformVersionCode .. "" then
		        	rmdir(f.."/")
	        	end
		    end
		end
	end
end

return PokerApp
	