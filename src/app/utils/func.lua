--
-- Author: shineflag
-- Date: 2017-02-26 11:00:56
--
local platformEventHalper = require("app.utils.platformEventHalper")

-- local function dump(obj)
--     local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
--     getIndent = function(level)
--         return string.rep("\t", level)
--     end
--     quoteStr = function(str)
--         return '"' .. string.gsub(str, '"', '\\"') .. '"'
--     end
--     wrapKey = function(val)
--         if type(val) == "number" then
--             return "[" .. val .. "]"
--         elseif type(val) == "string" then
--             return "[" .. quoteStr(val) .. "]"
--         else
--             return "[" .. tostring(val) .. "]"
--         end
--     end
--     wrapVal = function(val, level)
--         if type(val) == "table" then
--             return dumpObj(val, level)
--         elseif type(val) == "number" then
--             return val
--         elseif type(val) == "string" then
--             return quoteStr(val)
--         else
--             return tostring(val)
--         end
--     end
--     dumpObj = function(obj, level)
--         if type(obj) ~= "table" then
--             return wrapVal(obj)
--         end
--         level = level + 1
--         local tokens = {}
--         tokens[#tokens + 1] = "{"
--         for k, v in pairs(obj) do
--             tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
--         end
--         tokens[#tokens + 1] = getIndent(level - 1) .. "}"
--         return table.concat(tokens, "\n")
--     end
--     return dumpObj(obj, 0)
-- end

local wait_view_index = 0


local function hide_wait_view()
    local scheduler = require("framework.scheduler")
    wait_view_index = wait_view_index - 1
    if not tolua.isnull(tt.loading) and wait_view_index <= 0 then
        tt.loading.anim_sprite:stopAllActions()
        tt.loading.close_btn:stopAllActions()
        tt.loading:stopAllActions()
        tt.loading:setVisible(false)
    end
end

local function show_wait_view(str)
    local scheduler = require("framework.scheduler")
    str = str or ""
    local run_scene = display.getRunningScene()

    print("show_wait_view",tolua.isnull(tt.loading))
    if tolua.isnull(tt.loading) then
        local node, width, height = cc.uiloader:load("loading_view.json")
        -- local frames = display.newFrames("anim/load/%d.png",1, 8)
        node.anim_sprite = cc.uiloader:seekNodeByName(node, "loading_anim")
        -- node.lable_txt = cc.uiloader:seekNodeByName(node, "loading_txt")
        node.close_btn = cc.uiloader:seekNodeByName(node, "close_btn")
            :onButtonClicked(hide_wait_view)
        node:setTouchEnabled(true)
        node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                print(event.x,event.y)
                return true 
            end)
        node:setPosition(display.cx- 640,display.cy - 360)
        tt.loading = node
    end
    if run_scene ~= tt.loading:getParent() then
        run_scene:addChild(tt.loading,10000)
    end
    print("show_wait_view",wait_view_index)
    if wait_view_index <= 0 then
        local index = 0
        tt.loading.anim_sprite:schedule(function()
                index = (index + 40) % 360
                tt.loading.anim_sprite:rotation(index)
            end,0.1)
        tt.loading:performWithDelay(function()
                tt.loading:setVisible(true)
            end, 1)
        tt.loading.close_btn:stopAllActions()
        tt.loading.close_btn:setVisible(false)
        tt.loading.close_btn:performWithDelay(function()
                print("show_wait_view performWithDelay",wait_view_index)
                tt.loading.close_btn:setVisible(true)
            end, 3)
    end
    -- tt.loading.lable_txt:setString( tostring(str) or "")
    wait_view_index = wait_view_index + 1
end

local message_bg = nil
local function show_message(msg,func)
    print("show_message",msg)
    if not tolua.isnull(message_bg) then message_bg:removeSelf() end
    local run_scene = display.getRunningScene()
    message_bg = app:createView("MessageView", run_scene)
    message_bg:addTo(run_scene,10000)
    message_bg:show(msg,func)

    -- bg = display.newSprite("dec/weak_hint.png")
    -- local msize = bg:getContentSize()

    -- message_bg = display.newClippingRectangleNode()
    -- message_bg:setClippingRegion(cc.rect(display.cx - 640, display.cy - 360, 1280, 720))
    --     :addTo(run_scene)
        
    -- bg:addTo(message_bg)

    -- local label = display.newTTFLabel({
    --     text = tostring(msg),
    --     size = 60,
    --     color=cc.c3b(0xff,0xff,0xff),
    --     align = cc.TEXT_ALIGNMENT_CENTER,
    --     valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    --     dimensions = cc.size(1180, 0)
    -- }):addTo(bg)

    -- local txtSize = label:getContentSize()
    -- local h = math.max(txtSize.height + 80,msize.height)
    -- local scale = h/msize.height
    -- bg:setScaleY(scale)
    -- label:setScaleY(1/scale)
    -- label:setPosition(640 ,(h+40)/2/scale)

    -- local top = display.cy + 360
    -- bg:setPosition(display.cx,top + h/2)
    -- local sequence = transition.sequence({
    --     cc.MoveTo:create(0.5, cc.p(display.cx, top - h/2 )),
    --     cc.DelayTime:create(5),
    --     cc.MoveTo:create(0.5, cc.p(display.cx, top + h/2)),
    --     -- cc.FadeOut:create(1),
    --     cc.CallFunc:create(function() message_bg:removeSelf() end)

    -- })
    -- sequence:setTag(1)
    -- bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    --         local name, x, y = event.name, event.x, event.y
    --         -- print('--------------')
    --         if name == "ended" then
    --             bg:stopActionByTag(1)
    --             bg:setTouchEnabled(false)
    --             local x,y = bg:getPosition()
    --             -- print(x,y)
    --             local factor = math.abs((y - top) / (h/2))
    --             -- print(0.5*factor)
    --             local sequence = transition.sequence({
    --                 cc.MoveTo:create(0.5*factor, cc.p(display.cx, top + h/2)),
    --                 -- cc.FadeOut:create(1),
    --                 cc.CallFunc:create(function() message_bg:removeSelf() end)
    --             })
    --             sequence:setTag(1)
    --             bg:runAction(sequence)
    --         end
    --         return true
    --     end)
    -- bg:setTouchEnabled(true)
    -- bg:setCascadeOpacityEnabled(true)
    -- bg:runAction(sequence)
end

--全局显示的layer层
local function show_error(msg)
    print('---show_error--',msg)
    if not tt.glayer then
        tt.glayer = display.newLayer():setContentSize(display.width, display.height)
        cc.Director:getInstance():setNotificationNode(tt.glayer)
    end
    if not tt.glabel then
        tt.glabel = display.newTTFLabel({
            text = "",
            size = 30,
            x = display.cx,
            y = display.cy,
            color=cc.c3b(0xff,0x00,0x00),
            dimensions = cc.size(display.width,display.height)
        }):addTo(tt.glayer)
    end
    tt.glabel:setString(tostring(msg))
end


--[[发牌动画
--spos --起始位置
--epos --结束位置
--t    --时间
--f    --结束后执行函数
]]
local function play_coin_fly(spos,epos,t, f)

    local coin_img = display.newSprite("icon/icon_chip.png")
        :setPosition(spos)
    transition.moveTo(coin_img, {x = epos.x, y = epos.y, time = t or 0.2,
        onComplete = function()
            if not tolua.isnull(coin_img) then
                coin_img:removeSelf()
            end
            if f then
                f()
            end
        end})
    tt.play.play_sound("chips")
    return coin_img
end

--[[发牌动画
--spos --起始位置
--epos --结束位置
--t    --时间
--f    --结束后执行函数
]]
local function play_deal_cards(spos,epos,t, f)
    local node = display.newNode()
    local poker_img = display.newSprite("poker/poker_cad81_108/card_back.png")
        :addTo(node)
    local poker_img2 = display.newSprite("poker/poker_cad81_108/card_back.png")
        :addTo(node)
    local time = t or 1

    poker_img:setScale(0.38)
    poker_img2:setScale(0.38)
    poker_img:setPosition(spos)
    poker_img2:setPosition(spos)
    poker_img:rotation(100)
    poker_img2:rotation(100)
    
    local length = cc.pGetLength(spos,epos)
    local angle = math.abs(length) * 1.8
    local epos2 = cc.pAdd(epos,cc.p(35,-4))
    
    local moveAction = cc.MoveTo:create(time, cc.p(epos.x,epos.y))
    local moveAction2 = cc.MoveTo:create(time, cc.p(epos2.x,epos2.y))
    local rotateAction =  cc.RotateTo:create(time, angle-15.00)
    local rotateAction2 =  cc.RotateTo:create(time, angle+3.00)
    local fadeOut = cc.FadeOut:create(time)
    local fadeOut2 = cc.FadeOut:create(time)

    local action = cc.Spawn:create({moveAction,rotateAction})
    local action2 = cc.Spawn:create({moveAction2,rotateAction2})

    transition.execute(poker_img,action,{
            easing={"exponentialOut",3},
        })
    transition.execute(poker_img2,action2,{
            easing={"exponentialOut",3},
        })
    transition.execute(poker_img,fadeOut)
    transition.execute(poker_img2,fadeOut2)
    -- transition.moveTo(poker_img, {
    --         x=epos.x,
    --         y=epos.y,
    --         time=time,
    --         easing="exponentialOut",
    --     })

    -- transition.moveTo(poker_img2, {
    --         x=epos2.x,
    --         y=epos2.y,
    --         time=time,
    --         easing="exponentialOut",
    --     })


    -- poker_img:rotation(100)
    -- poker_img2:rotation(100)

    -- transition.rotateTo(poker_img, {
    --         rotate=angle-15.00,
    --         time=time,
    --         easing="exponentialOut",
    --     })

    -- transition.rotateTo(poker_img2, {
    --         rotate=angle+3.00,
    --         time=time,
    --         easing="exponentialOut",
    --     })

    node:performWithDelay(function()
            if not tolua.isnull(node) then
                node:removeSelf()
            end
            if f then
                f()
            end
        end, time)
    return node
end


-- local function decodeURI(s)
--     s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
--     return s
-- end

-- local function encodeURI(s)
--     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
--     return string.gsub(s, " ", "+")
-- end


local function asynGetHeadIconSprite(img_url_,callback)
    print("asynGetHeadIconSprite:%s",img_url_ or "")
    if not img_url_ or img_url_ == "" then
        return 
    end
    if img_url_ == "file://dec/morentouxiang.png" then 
        img_url_ = "file://dec/def_head1.png"
    end
    if string.sub(img_url_,1,7) == "file://" then
        local path = cc.FileUtils:getInstance():fullPathForFilename(string.sub(img_url_,8))
        if io.exists(path) then
            callback(display.newSprite(string.sub(img_url_,8)))
        else
            print("asynGetHeadIconSprite not io.exists:%s",img_url_ or "")
        end
        return 
    end

    if string.sub(img_url_,1,7) == "http://" or string.sub(img_url_,1,8) == "https://" then
        local sprite = tt.imageCacheManager:newCacheSprite(img_url_)
        if not sprite then
            print("asynGetHeadIconSprite download",img_url_)
            tt.imageCacheManager:downloadImage(img_url_, function(url)
                local sprite = tt.imageCacheManager:newCacheSprite(img_url_)
                if sprite then
                    callback(sprite)
                end
            end)
        else
            print("asynGetHeadIconSprite cacheData",img_url_)
            callback(sprite)
        end
        return 
    end
end


local function getNumStr(num)
    local ret = ""
    -- num = 2384788346
    num = tonumber(num) or 0
    if num == 0 then return "0" end

    if num >= 100000000 then
        local f = num % 1000000
        num = (num - f) / 1000000
        ret = string.format(".%02dM",(f-f%10000)/10000)
    end

    while num > 0 do
        local f = num % 1000
        num = (num - f) / 1000
        if num > 0 then
            ret = string.format(",%03d%s",f,ret)
        else
            ret = string.format("%d%s",f,ret)
        end
    end
    return ret
end

local function getBitmapNum(filestr,num)
    local node = display.newNode()
    node:setAnchorPoint(cc.p(0,0))
    local numImg = {}
    local w = 0
    local h = 0

    if num == 0 then 
        local sprite = display.newFilteredSprite(string.format(filestr,num))
        table.insert(numImg, 1,sprite)
    else
        while (num > 0) do
            local index = num % 10
            num = (num - index) / 10
            local sprite = display.newFilteredSprite(string.format(filestr,index))
            table.insert(numImg, 1,sprite)
        end
    end 
    for i,img in ipairs(numImg) do
        img:setAnchorPoint(cc.p(0,0))
        :setPosition(cc.p(w,0))
        :addTo(node)
        w = w + img:getContentSize().width
        h = img:getContentSize().height
    end
    node:setContentSize(w,h)
    return node,numImg
end

local function getBitmapNumStr(filestr,num)
    local node = display.newNode()
    node:setAnchorPoint(cc.p(0,0))
    local numImg = {}
    local w = 0
    local h = 0
    local numStr = getNumStr(num)
    local len = #numStr

    for i=1,len do
        local c = string.sub(numStr,i,i)
        local num
        if c == ',' then
            num = 10
        elseif c == '.' then
            num = 11
        elseif c == 'M' then
            num = 12
        else
            num = tonumber(c)
        end
        if num then
            local sprite = display.newFilteredSprite(string.format(filestr,num))
            table.insert(numImg,sprite)
        end
    end

    for i,img in ipairs(numImg) do
        img:setAnchorPoint(cc.p(0,0))
        :setPosition(cc.p(w,0))
        :addTo(node)
        w = w + img:getContentSize().width
        h = img:getContentSize().height
    end
    node:setContentSize(w,h)
    return node,numImg
end

function tt.getBitmapStrAscii(filestr,str,offset_w)
    local str = tostring(str) or ""
    local node = display.newNode()
    node:setAnchorPoint(cc.p(0,0))
    local strImg = {}
    local w = 0
    local h = 0
    local len = #str
    offset_w = offset_w or 0
    for i=1,len do
        local c = string.sub(str,i,i)
        local num = string.byte(c)
        -- print(num)
        if num then
            local sprite = display.newFilteredSprite(string.format(filestr,num))
            table.insert(strImg,sprite)
        end
    end

    for i,img in ipairs(strImg) do
        img:setAnchorPoint(cc.p(0,0))
        :setPosition(cc.p(w,0))
        :addTo(node)
        w = w + img:getContentSize().width + offset_w
        h = img:getContentSize().height
    end
    node:setContentSize(w,h)
    return node,strImg
end


function tt.linearlayout(view,add,x,y)
    local w = view:getContentSize().width
    x = x or 0
    y = y or 0
    -- printInfo("linearlayout %d", w)
    add:addTo(view)
    local size = add:getContentSize()
    local scaleX = add:getScaleX()
    local scaleY = add:getScaleY()
    local p = add:getAnchorPoint()
    add:setPosition(cc.p(x+w+size.width*scaleX*p.x,y+size.height*scaleY*p.y))

    view:setContentSize(x+w+size.width*scaleX,view:getContentSize().height)
end

function tt.makeScreen(callb)
    local net = require("framework.cc.net.init")
    local fileName = string.format("printScreen_%d.png",math.ceil(net.SocketTCP.getTime()*1000)) 

    display.captureScreen(function(succeed, outputFile)  
    if succeed then  
        if callb then
            callb(outputFile)
        end
        os.remove(fileName)
        display.removeSpriteFrameByImageName(fileName)  
    else  
        printError("makeScreen fail")
    end  
  end, fileName)
end

function tt.makeScreenBlur(callb)
    makeScreen(function ( outfile )
        -- local sprite_photo = cc.FilteredSpriteWithMulti:create(outfile)
        -- -- sprite_photo:setScale(750/display.widthInPixels)
        -- sprite_photo:setFilters({cc.GaussianVBlurFilter:create(3),cc.GaussianHBlurFilter:create(3)})


        local run_scene = display.getRunningScene()
        local maskArgs = {
            -- filters = {"GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"},
            -- filterParams = { {3}, {3}}
            -- filters = "MOTION_BLUR",
            -- filterParams =  {3, 3} 
            -- filters = "ZOOM_BLUR",
            -- filterParams =  {1, 0.5, 0.5} 
            filters = "CUSTOM",
            filterParams = json.encode({frag = "shaders/example_Blur.fsh",
            shaderName = "blurShader",
            resolution = {display.width,display.height},
            blurRadius = 16,
            sampleNum = 5})
        --     filters={"CUSTOM", "CUSTOM"},
        -- filterParams = {json.encode({frag = "Shaders/example_Blur.fsh",
        --     shaderName = "blurShader",
        --     resolution = {480,320},
        --     blurRadius = 10,
        --     sampleNum = 5}),
        -- json.encode({frag = "Shaders/example_sepia.fsh",
        --     shaderName = "sepiaShader",})},
        }

        local sprite_photo = display.newFilteredSprite(outfile,maskArgs.filters,maskArgs.filterParams)
        sprite_photo:setScale(1/display.contentScaleFactor)

        callb(sprite_photo)
    end)
end


tt.displayWebView = function(x,y,width,height,showClose)
    local params = platformEventHalper.cmds.displayWebView
    params.args = {
        x=x*display.contentScaleFactor,
        y=display.heightInPixels-y*display.contentScaleFactor,
        width=width*display.contentScaleFactor,
        height=height*display.contentScaleFactor,
        showClose = showClose == true,
    }
    platformEventHalper.callEvent(params)
end

tt.dismissWebView = function()
    platformEventHalper.callEvent(platformEventHalper.cmds.dismissWebView)
end

tt.webViewLoadUrl = function(url)
    local params = platformEventHalper.cmds.webViewLoadUrl
    params.args = {
        url=url,
    }
    platformEventHalper.callEvent(params)
end

tt.isWebViewVisible = function()
    local ok,ret = platformEventHalper.callEvent(platformEventHalper.cmds.isWebViewVisible)
    if ok then
        return ret
    else
        return false
    end
end

function tt.limitStr(view,str,width)
    view:setString(str)
    local size = view:getContentSize()
    local addStr = '***'
    while size.width > width and string.utf8_len(str) > 0 do
        print("tt.limitStr",str)
        str = string.utf8_sub(str,1,-2)
        view:setString(str .. addStr)
        size = view:getContentSize()
    end
end

tt.makePoint = function(x,y,radius,startAngle,endAngle,segments)
    -- printInfo("makeVertexs %d %d %d %d %d ", x,y,radius,startAngle,endAngle)
    local segments = segments or 32
    local startRadian = 0
    local endRadian = math.pi * 2
    local posX = x or 0
    local posY = y or 0
    if startAngle then
        startRadian = math.angle2radian(startAngle)
    end
    if endAngle then
        endRadian = math.angle2radian(endAngle)
    end
    local radianPerSegm = (endRadian-startRadian) / segments
    local points = {}
    points[#points + 1] = {posX + radius * math.cos(startRadian), posY + radius * math.sin(startRadian)}
    for i = 1, segments-1 do
        local radii = startRadian + i * radianPerSegm
        -- printInfo("radii %f", radii)
        points[#points + 1] = {posX + radius * math.cos(radii), posY + radius * math.sin(radii)}
    end
    points[#points + 1] = {posX + radius * math.cos(endRadian), posY + radius * math.sin(endRadian)}
    return points
end

function tt.getDrewardInfo(data,sign_num,oRank)
    local pnum = data.pnum
    local rank = data.rank
    local reward_per = data.reward_per
    local row
    local col = #pnum

    for i,v in ipairs(rank) do
        if v >= oRank then
            row = i
            break
        end
    end 
    if not row then return 0 end

    for i,v in ipairs(pnum) do
        if v <= sign_num then
            col = i
            break
        end
    end
    return reward_per[row][col] or 0
end

function tt.getSuitableGoodsByMoney(lack_money)
    local pmodeInfos = tt.nativeData.getShopInfo()
    local smsInfos = nil -- 短代
    local dInfos = nil -- 应用内支付
    for _,pmodeInfo in ipairs(pmodeInfos) do
        if pmodeInfo.pmode == 3 then
            smsInfos = pmodeInfo
        elseif pmodeInfo.pmode == 1 then
            dInfos = pmodeInfo
        elseif pmodeInfo.pmode == 2 then
            dInfos = pmodeInfo
        end
    end
    local goods = {}
    local minGoods
    local maxGoods
    
    if smsInfos then
        for k,v in ipairs(smsInfos.goods) do
            table.insert(goods,v)
        end
    end

    if dInfos then
        for k,v in ipairs(dInfos.goods) do
            table.insert(goods,v)
        end
    end

    for k,v in ipairs(goods) do
        if v.coin >= lack_money then
            if not minGoods or minGoods.coin > v.coin then
                minGoods = v
            end
        end
        if not maxGoods or v.coin > maxGoods.coin then
            maxGoods = maxGoods
        end
    end

    if minGoods then return minGoods end
    return maxGoods
end

function tt.checkBankruptcy()
    print("checkBankruptcy")
    local cash_data = tt.nativeData.getCashInfo()
    local minCash
    for k,v in ipairs(cash_data) do
        if not minCash or v.default_buy < minCash.default_buy then
            minCash = v
        end
    end
    print("checkBankruptcy",minCash)
    dump(minCash,"checkBankruptcy")
    if minCash then return tt.owner:getMoney() < minCash.default_buy end
    return false
end

function tt.getNumShortStr(num)
    num = tonumber(num) or 0
    local K = 1000
    local M = 1000 * K
    local B = 1000 * M 
    local T = 1000 * B
    local ret = tostring(num) or "0"
    if num >= T then
        ret = string.format("%dT",num / T) 
    elseif num >= B then
        ret = string.format("%dB",num / B) 
    elseif num >= M then
        ret = string.format("%dM",num / M) 
    elseif num >= 10 * K then
        ret = string.format("%dK",num / K) 
    end
    return ret
end

function tt.getNumShortStr2(num)
    num = tonumber(num) or 0
    local K = 1000
    local M = 1000 * K
    local B = 1000 * M
    local T = 1000 * B
    local ret = tostring(num) or "0"
    if num >= T then
        ret = string.format("%.04fT",num / T) 
    elseif num >= B then
        ret = string.format("%.04fB",num / B) 
    elseif num >= M then
        ret = string.format("%.04fM",num / M) 
    elseif num >= K then
        ret = string.format("%.04fK",num / K) 
    end
    local len = #ret
    local lc = string.sub(ret,len,len)
    if lc == "B" or lc == "M" or lc == "K" then
        local index = 0
        for i=1,len do
            local c = string.byte(ret,i)
            if c >= 48 and c <= 57 then
                index=index+1
                if index == 5 then
                    ret = string.sub(ret,1,i) .. lc
                    break
                end
            end
        end

        local len2 = #ret
        for i=len2-1,1,-1 do
            local c = string.byte(ret,i)
            if c == 48 then
                ret = string.sub(ret,1,i-1) .. lc
            elseif c == 46 then
                ret = string.sub(ret,1,i-1) .. lc
                break
            else
                break
            end
        end
    end
    return ret
end


function tt.getNumStr2(num)
    local ret = ""
    -- num = 2384788346
    num = tonumber(num) or 0
    if num == 0 then return "0" end
    
    while num > 0 do
        local f = num % 1000
        num = (num - f) / 1000
        if num > 0 then
            ret = string.format(",%03d%s",f,ret)
        else
            ret = string.format("%d%s",f,ret)
        end
    end
    return ret
end

local utime = os.time()
local otime = 0
function tt.updateUtime(time)
    utime = tonumber(time) or utime
    otime = os.time() - utime
    print("updateUtime",otime,os.time(),utime)
end

function tt.time()
    return os.time() - otime
end

function tt.getVpName(vpLv)
    if vpLv == 1 then
        return tt.gettext("青铜")
    elseif vpLv == 2 then
        return tt.gettext("白银")
    elseif vpLv == 3 then
        return tt.gettext("黄金")
    elseif vpLv == 4 then
        return tt.gettext("红宝石")
    elseif vpLv == 5 then
        return tt.gettext("祖母绿")
    elseif vpLv == 6 then
        return tt.gettext("蓝钻石")
    end
    return ""
end

function tt.fixBackgroudWidth(view,backgroud,defaultWidth,widthAdd)
    widthAdd = checknumber(widthAdd)
    defaultWidth = checknumber(defaultWidth)
    local size = view:getContentSize()
    local width = math.max(size.width + widthAdd,defaultWidth)
    backgroud:setContentSize(width,backgroud:getContentSize().height)
end

tt.show_error = show_error
-- tt.dump = dump
tt.show_msg = show_message
tt.play_coin_fly = play_coin_fly
tt.play_deal_cards = play_deal_cards
tt.show_wait_view = show_wait_view
tt.hide_wait_view = hide_wait_view
-- tt.decodeURI = decodeURI
-- tt.encodeURI = encodeURI
tt.asynGetHeadIconSprite = asynGetHeadIconSprite
tt.getBitmapNum = getBitmapNum
tt.getBitmapNumStr = getBitmapNumStr
tt.getNumStr = getNumStr