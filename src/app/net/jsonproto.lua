--
-- Author: shineflag
-- Date: 2017-02-15 18:04:23
--
-- @see http://underpop.free.fr/l/lua/lpack/
require("pack")
require("app.utils.sutils")

local head = 2

local protos = require("app.net.protos")

local function _unpack(data,uncrypt)
	local next, len = string.unpack(data,">H")
	local info = data:sub(next, head+len)
	print("before decrypt #data #info next len info",#data,#info, next, len, info)
	if not uncrypt then
		info = string.decrypt(info)
	end
	print("after decrypt",#info,info)
	return json.decode(info)
end

local function _pack(data,uncrypt)
	local info = json.encode(data)
	--print("before crypt",#info,info)
	if not uncrypt then 
		info = string.encrypt(info)
	end
	--print("after crypt",#info,info)
	local head = string.pack(">H",#info)
	local packed = head .. info 
	return packed
end

--创建一个请求的包
local function create_req(cmd,args,uncrypt)

	local p = protos[cmd]
	if p then
		local data = {}
		data.cmd = cmd 
		if p.req then
			local req = {}
			for key,value in pairs(p.req) do 
				if args[key] then
					req[key] = args[key]
				else
					req[key] = value
				end
			end

			data.req = req
		end

		return _pack(data,uncrypt)
	end

	return nil 

end

--根据参数创建一个回复包
local function create_resp(cmd,args,uncrypt)

	local p = protos[cmd]
	if p then
		local data = {}
		data.cmd = cmd 
		if p.resp then
			local resp = {}
			for key,value in pairs(p.resp) do 
				if args and args[key] then
					resp[key] = args[key]
				else
					resp[key] = value
				end
			end

			data.resp = resp
		end

		return _pack(data,uncrypt)
	end

	return nil 
end

--根据参数创建一个server主动推送的包
local function create_push(cmd,args,uncrypt)

	local p = protos[cmd]
	if p then
		local data = {}
		data.cmd = cmd 
		if p.push then
			local push = {}
			for key,value in pairs(p.push) do 
				if args and args[key] then
					resp[key] = args[key]
				else
					push[key] = value
				end
			end

			data.push = push
		end

		return _pack(data,uncrypt)
	end

	return nil 
end




local proto = {}
proto.create_req = create_req
proto.create_resp = create_resp 
proto.create_push = create_push
proto.unpack = _unpack 
proto.pack = _pack
proto.protos = protos
return proto