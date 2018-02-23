local game_data = require("app.utils.game_data")
local scheduler = require("framework.scheduler")
local handler = nil
local PropDataHelper = {}
local callbacks = {}
local pids = {}

function PropDataHelper.register(pid,callback)
	if not callbacks[pid] then callbacks[pid] = {} end
	table.insert(callbacks[pid],callback)
	pids[pid] = true
	if not handler then
		handler = scheduler.scheduleUpdateGlobal(PropDataHelper.update)
	end
	return callback
end

function PropDataHelper.update()
	if not next(callbacks) then
		scheduler.unscheduleGlobal(handler)
		handler = nil
		return
	end
	local send_pids = {}
	for pid,v in pairs(pids) do
		local propData = game_data.getPropData(pid)
		if propData then
			local cbs = callbacks[pid]
			for _,callback in ipairs(cbs) do
				callback(propData)
			end
			callbacks[pid] = nil
		else
			tt.ghttp.request(tt.cmd.selectShop,{pids={pid}})
			-- table.insert(send_pids,pid)
		end
	end
	-- if next(send_pids) then
	-- 	tt.ghttp.request(tt.cmd.selectShop,{pids=send_pids})
	-- end
	pids = {}
	for pid,cbs in pairs(callbacks) do
		local propData = game_data.getPropData(pid)
		if propData then
			for _,callback in ipairs(cbs) do
				callback(propData)
			end
			callbacks[pid] = nil
		end
	end
end

function PropDataHelper:unregister(pid,dcallback)
	if callbacks[pid] then 
		for i,callback in ipairs(callbacks[pid]) do
			if dcallback == callback then
				table.remove(callbacks[pid],i)
				break
			end
		end
		if not next(callbacks[pid]) then callbacks[pid] = nil end
	end
end

return PropDataHelper