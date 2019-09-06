local ffi = require("ffi")
local consts = require("defines")
local signatures = require("signatures")

local M = {}
local function ptr(n)
	return tonumber(ffi.cast("uint64_t", n))
end

function M.str2val(str)
	local cached = const_strings[str]
	if cached then
		return cached
	end
	local idx = signatures.GetStringTableIndex(str, 0, 1)
	return ffi.new("Value", {type = consts.String, value = idx})
end

function M.str2index(str)
	local cached = const_strings[str]
	if cached then
		return cached.value
	end
	return signatures.GetStringTableIndex(str, 0, 1)
end

M.luaHandlers = {
	[consts.String] = function(val)
		return M.idx2str(val.value)
	end,
	[consts.Number] = function(val)
		return tonumber(val.valuef)
	end,
	[consts.Null] = function()
		return nil
	end
}

for k, v in pairs {consts.MobType, consts.ObjType, consts.DatumType, consts.ClientType} do
	M.luaHandlers[v] = function(val)
		return M.idx2str(signatures.Path2Text(val.type, val.value))
	end
end

function M.toLua(value)
	local t = M.luaHandlers[tonumber(value.type)]
	if t then
		return t(value)
	else
		print("??? value2lua type: " .. value)
	end
end
--use refcount if we're assigning or invoking
function M.toValue(value, refcount)
	local t = type(value)
	if t == "string" then --NYI: port to table accessors
		local cached = const_strings[str]
		if cached then
			return cached
		end
		if refcount then
			idx = signatures.GetStringTableIndex(value, 0, 1)
			ref = signatures.GetStringTableIndexPtr(idx)
			ref.refcount = ref.refcount + 1
			return ffi.new("Value", {type = consts.String, value = idx})
		else
			return ffi.new("Value", {type = consts.String, value = signatures.GetStringTableIndex(value, 0, 1)})
		end
	elseif t == "number" then
		return ffi.new("Value", {type = consts.Number, valuef = value})
	elseif t == "boolean" then
		return ffi.new("Value", {type = consts.Number, valuef = value and 1 or 0})
	elseif t == "nil" then
		return consts.null
	elseif t == "table" then
		local mt = getmetatable(value)
		if mt == require "datum".type or mt == require "list".type then
			return value.handle
		elseif not mt then
			local function ilen(t)
				local i = 0
				for _ in pairs(t) do
					i = i + 1
					if t[i] == nil then
						return 0
					end
				end
				return i
			end

			local list_id = signatures.CreateList(ilen(value))
			local newlist =
				setmetatable(
				{
					internal_list = signatures.GetListArrayEntry(list_id),
					handle = ffi.new("Value", {type = consts.List, value = list_id})
				},
				require "list".type
			)
			for k, v in pairs(value) do
				newlist[k] = v
			end
			return M.toValue(newlist)
		end
	else
		print("??? type: " .. t)
	end
end

const_strings = {}
local current_string = ""
local current_char = signatures.GetStringTableIndexPtr(1).stringData
local i = 0
local string_id = 1
while true do
	if current_char[i] == 0 then
		const_strings[current_string] = ffi.new("Value", {type = consts.String, value = string_id})
		const_strings[string_id] = const_strings[current_string]
		if tonumber(current_char[i + 1]) <= 0 then
			break
		else
			current_string = ""
			string_id = string_id + 1
		end
	else
		if tonumber(current_char[i]) < 0 then
			break
		end
		current_string = current_string .. string.char(tonumber(current_char[i]))
	end
	i = i + 1
end

local strcache = {}
function M.idx2str(index)
	if index == 0xFFFF then
		return ""
	end
	--null or blank string not sure which is more proper
	if strcache[tonumber(idx)] then
		return strcache[tonumber(idx)]
	end
	local entry = signatures.GetStringTableIndexPtr(index)
	if entry == ffi.null then
		return
	end
	local cache = ffi.string(entry.stringData)
	strcache[tonumber(index)] = cache
	return cache
end

function M.text2path(text)
	return signatures.Text2Path(signatures.GetStringTableIndex(text, 0, 1))
end

return M
