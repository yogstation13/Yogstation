local ffi = require("ffi")
local consts = require("defines")
local signatures = require("signatures")
local t2t = require("type2type")

local M = require "byond"
local meta = {}

t2t.luaHandlers[consts.MobType] = function(val)
	return M.typecache.mobtypes[val.value]
end

for k, v in pairs {
	consts.ObjType,
	consts.DatumType,
	0x0A, --todo, give names
	0x0B
} do
	t2t.luaHandlers[v] = function(val)
		return M.typecache.types[val.value]
	end
end

M.typecache = {
	types = {},
	mobtypes = {}
}

function meta:__toString()
	return self.path
end

function add_type_entry(i, entry)
	local built =
		setmetatable(
		{
			id = i,
			type = entry,
			path = t2t.idx2str(entry.path),
			parentType = entry.parentTypeIdx,
			typeName = t2t.idx2str(entry.last_typepath_part),
			parentCache = {}
		},
		meta
	)
	M.typecache.types[i] = built
	M.typecache.types[built.path] = built
end

for i = 0, 0xFFFFFF do
	local entry = signatures.GetTypeTableIndexPtr(i)
	if entry ~= ffi.null then
		add_type_entry(i, entry)
	else
		print("Indexed " .. tostring(i) .. " types.")
		break
	end
end

for k, v in ipairs(M.typecache.types) do
	local parent = M.typecache.types[v.parentType]
	if not parent then
		M.typecache.types[k].parentType = v
		M.typecache.types[v.path].parentType = v
	else
		M.typecache.types[k].parentType = parent
		M.typecache.types[v.path].parentType = parent
	end
end

for k, v in ipairs(M.typecache.types) do
	orig_type = v
	repeat
		orig_type.parentCache[v.parentType] = 1
		v = v.parentType
	until v.parentType == v
	M.typecache.types[orig_type.path].parentCache = orig_type.parentCache
end

for i = 0, 0xFFFFFF do
	local g_index = signatures.MobTableIndexToGlobalTableIndex(i)
	if g_index == ffi.null then
		break
	end
	M.typecache.mobtypes[i] = M.typecache.types[g_index[0]]
	M.typecache.mobtypes[M.typecache.types[g_index[0]].path] = M.typecache.types[g_index[0]]
end

function M.T(typepath)
	return M.typecache.types[typepath]
end

function M.istype(thingy, wtype)
	return thingy.type.parentCache[wtype] and true or false
	--[[thingy_type = thingy.type -- time-memory tradeoff here
	if thingy_type == wtype then
		return true
	end
	repeat
		thingy_type = thingy_type.parentType
		if thingy_type == wtype then
			return true
		end
	until thingy_type.parentType == thingy_type
	return false]]
end

return M
