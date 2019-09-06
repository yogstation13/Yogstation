local t2t = require "type2type"
local ffi = require("ffi")
local signatures = require "signatures"
local constants = require "defines"
--local debugger = require "debugger"

local M = require "byond"
M.procHooks = {}
local typecache = {
	procs = {}
}

local procMeta = {}
procMeta.__index = procMeta
function procMeta:__tostring()
	return "[BYOND Proc #" .. self.id .. "]: " .. self.path
end

function procMeta:hook(callback)
	print("proc hook added: " .. self.name)
	M.procHooks[self.id] = callback
end

--[[function procMeta:set_breakpoint()
	local setup = M.getProcSetupInfo(self.path)
	debugger.replaced_opcode = setup.bytecode[0]
	debugger.bytecode_len = setup.bytecode_len
	setup.bytecode[0] = 0x1337
	M.set_breakpoint_func(debugger.debug_hook)
end]]
function procMeta:__call(...)
	local args = {...}
	local argv = {}
	for i = 1, #args do
		local v = t2t.toValue(args[i], true)
		if v then
			table.insert(argv, v)
		end
	end
	local vals = ffi.new("Value[" .. #argv .. "]", argv)
	return t2t.toLua(
		signatures.CallGlobalProc(0, 0 --[[no src]], 2, self.id, 0, 0, 0, vals, #argv, 0, 0 --[[no callback]])
	)
end

M.proc_setup_table_length = (signatures.AlmostTotalProcs + 1)[0]

local setup_meta = {}

function setup_meta.__newindex(self, key, val)
	if key == "local_var_count" then
		signatures.ProcSetupTable[self.__proc.proc.local_var_count_idx][0].local_var_count = val
	elseif key == "bytecode" then
		signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].bytecode = val
		signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].bytecode_length = ffi.sizeof(val) / 4 --assuming each opcode is 4 bytes
	elseif key == "bytecode_len" then
		signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].bytecode_length = val
	end
end

function setup_meta.__index(self, key)
	if key == "local_var_count" then
		return signatures.ProcSetupTable[self.__proc.proc.local_var_count_idx][0].local_var_count
	elseif key == "bytecode" then
		return signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].bytecode
	elseif key == "bytecode_len" then
		return signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].bytecode_length --if you look up the proc by bytecode index, the local_var_count holds the length of the bytecode
	end
end

function M.getProcSetupInfo(path)
	local proc = M.getProc(path)
	return setmetatable(
		{
			__proc = proc
		},
		setup_meta
	)
end

for i = 0, 0xFFFFFF do
	local entry = signatures.GetProcArrayEntry(i)
	if entry ~= ffi.null then
		--print(i)
		--print(t2t.idx2str(entry.procPath), entry.unknown2)
		local built =
			setmetatable(
			{
				id = i,
				proc = entry,
				path = t2t.idx2str(entry.procPath),
				name = t2t.idx2str(entry.procName),
				category = t2t.idx2str(entry.procCategory),
				desc = t2t.idx2str(entry.procDesc),
				flags = tonumber(entry.procFlags)
			},
			procMeta
		)
		typecache.procs[i] = built
		typecache.procs[built.path] = built
	else
		print("Ran out of procs to hook")
		break
	end
end

function M.getProc(path)
	local ret = typecache.procs[path]
	if not ret then
		error("ERROR: " .. path .. " is not a valid proc!")
	end
	return ret
end

function M.getProcById(id)
	local ret = typecache.procs[id]
	if not ret then
		error("ERROR: " .. id .. " is not a valid proc ID!")
	end
	return ret
end

function M.allProcs()
	return typecache.procs
end

M.callGlobalProcHook =
	M.hook(
	signatures.CallGlobalProc,
	function(original, usrType, usrVal, flags, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
		--print("this message means code is working")
		--local theProc = signatures.GetProcArrayEntry(procid)
		--if byond.toLuaString(theProc.procPath) == '/proc/conoutput' and argc == 1 then
		--	print('dbg: ' ..byond.toLuaString(argv[0].value))
		--	return byond.null.longlongman
		--end
		if M.procHooks[tonumber(procid)] then
			local luad = {}
			for i = 1, tonumber(argc) do
				luad[i] = t2t.toLua(argv[i - 1])
				--dont skip arguments if they fail conversion
			end
			return t2t.toValue(
				M.procHooks[tonumber(procid)](
					function(...)
						local honk = {}
						for k, v in pairs {...} do
							honk[k] = t2t.toValue(v)
						end
						return t2t.toLua(
							original(
								usrType,
								usrVal,
								flags,
								procid,
								d,
								srcType,
								srcVal,
								ffi.new("Value[" .. #honk .. "]", honk),
								#honk,
								0,
								0
							)
						)
					end,
					t2t.toLua(ffi.new("Value", {type = usrType, value = usrVal})),
					t2t.toLua(ffi.new("Value", {type = srcType, value = srcVal})),
					unpack(luad)
				)
			).longlongman
		else
			local ret = original(usrType, usrVal, flags, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
			return ret.longlongman
		end
	end,
	"long long(*)(char usrType, int usrVal, int const_2, unsigned int proc_id, int const_0, char srcType, int srcVal, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3)",
	constants.null.longlongman
)

signatures.CallGlobalProcEx = signatures.CallGlobalProcEx or signatures.CallGlobalProc
signatures.CallGlobalProc = M.callGlobalProcHook.trampoline

M.QPFn = ffi.new("long long[1]")
print("QPF")
ffi.C.QueryPerformanceFrequency(M.QPFn)
M.QPFn = tonumber(M.QPFn[0])
M.QPCn = ffi.new("long long[1]")
round = function(x, factor) 
    local factor = (factor) and (10 ^ factor) or 0
    return math.floor((x + 0.5) * factor) / factor
end

M.sendMapsHook = M.hook(
	signatures.SendMaps,
	function(original)
		ffi.C.QueryPerformanceCounter(M.QPCn)
		local start_time = tonumber(M.QPCn[0]) / M.QPFn
		original()
		ffi.C.QueryPerformanceCounter(M.QPCn)
		local end_time = tonumber(M.QPCn[0]) / M.QPFn
		M.sendmaps_time = (end_time - start_time) * 10
	end,
	"void(*)(void)",
	ffi.null
)

return M
