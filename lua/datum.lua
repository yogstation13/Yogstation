local ffi = require("ffi")
local signatures = require("signatures")
local t2t = require "type2type"
local consts = require "defines"
local byond = require "byond"
local signatures = require "signatures"
local M = {}
--setmetatable(datumM, {__index=datumM})-- datumM.__index = datumM

local meta = {
	cached_type = nil
}
M.type = meta
function meta:__index(key)
	if key == "type" then
		local c = rawget(self, "cached_type")
		if c then
			return c
		end
		rawset(self, "cached_type", t2t.toLua(signatures.GetVariable(self.handle, t2t.str2index(key))))
		return self.cached_type
	end
	return rawget(meta, key) or t2t.toLua(signatures.GetVariable(self.handle, t2t.str2index(key)))
end

function meta:__newindex(key, val)
	if key == "type" then
		return
	end
	local converted = t2t.toValue(val, true) or M.null
	signatures.SetVariable(self.handle, t2t.str2index(key), converted)
end

function meta:invoke(procName, ...)
	--[[local proc = byond.getProc( procName )
	if not proc then error('no such proc ' .. procName) end]]
	procName = procName:gsub("_", " ")
	local args = {...}
	local argv = {}
	for i = 1, #args do
		local v = t2t.toValue(args[i], true)
		if v then
			table.insert(argv, v)
		end
	end
	local vals = ffi.new("Value[" .. #argv .. "]", argv)
	--return t2t.toLua(signatures.CallGlobalProcEx( 0, 0, 2, proc.id, 0, self.handle.type, self.handle.value, vals, #argv, 0, 0 --[[no callback]] ))
	return t2t.toLua(
		signatures.CallProc(
			0,
			0,
			2,
			t2t.str2index(procName),
			self.handle.type,
			self.handle.value,
			vals,
			#argv,
			0,
			0 --[[no callback]]
		)
	)
end

function meta:__eq(b)
	if not b then
		return self == M.null
	end
	if ffi.istype("Value", b) then
		return self.handle == b
	else
		return self.handle == b or self.handle == b.handle
	end
end

function meta:__tostring()
	return ("BYOND %s [0x%x%06x]"):format(consts.types[tonumber(self.handle.type)], self.handle.type, self.handle.value)
end

function meta:ref()
	return ("[0x%x%06x]"):format(self.handle.type, self.handle.value)
end

function M.fromValue(val)
	return setmetatable({handle = val}, meta)
end

function meta:istype(wtype)
	return self.type.parentCache[wtype] and true or false
end

function byond.new(path, ...)
	local args = {...}
	local argv = {}
	for i = 1, #args do
		local v = t2t.toValue(args[i], true)
		if v then
			table.insert(argv, v)
		end
	end
	local vals = ffi.new("Value[" .. #argv .. "]", argv)
	local b_path = t2t.toValue(path)
	signatures.New(b_path, vals, #argv, 0)
	return t2t.toLua(b_path)
end

for k, v in pairs {
	consts.Datum,
	consts.Turf,
	consts.World,
	consts.Obj,
	consts.Image,
	consts.Client,
	consts.Area,
	consts.Mob
} do
	t2t.luaHandlers[v] = M.fromValue
end

M.world = setmetatable({handle = {type = M.World, value = 0x0}}, meta)
M.global = setmetatable({handle = {type = M.World, value = 0x1}}, meta)
return M
