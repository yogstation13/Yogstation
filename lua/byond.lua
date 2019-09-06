local ffi = require("ffi")
local type2type = require "type2type"
local signatures = require "signatures"
local context = require "context"
local dbg = require "debugger"
local M = {}
local getmetatable = getmetatable
--local yolo = hook.sigscan("byondcore.dll", "?? ?? ?? ?? 8B F0 83 C4 04 85 F6 74 5F 0F B7 1E C1 E3 02 53 ")

--local idarr = ffi.cast('uint32_t*', yolo)
--GetIDArrayEntry = ffi.cast('GetIDArrayEntryPtr', idarr[0]+yolo+4)
local function ptr(n)
	return tonumber(ffi.cast("uint64_t", n))
end

local hooks = {}
function M.hook(fn, callback, cbType, errRet) --print('hooking thing', fn)do return end
	if hooks[fn] then
		local hk = hooks[fn]
		hk.func = callback
		return hk
	end

	cbType = ffi.typeof(cbType or fn)
	local entry = {}
	entry.func = callback
	local uCB = function(...)
		local suc, err = pcall(entry.func, entry.trampoline, ...)
		if not suc then
			print("HOOK ERROR: (dangerous!) " .. tostring(err))
			return errRet --[[eek]]
		end
		return err
	end
	jit.off(uCB)

	entry.cb = ffi.cast(cbType, uCB)
	jit.off(callback)

	local hook = hook.create(ptr(fn), ptr(entry.cb))
	local tramp = hook:hook()

	if tramp then
		entry.trampoline = ffi.cast(ffi.typeof(fn), tramp)
	else
		return nil
	end
	entry.hook = hook
	hooks[fn] = entry
	return entry
end

M.ptr = ptr

--[[M.breakpointHook =
	M.hook(
	signatures.TempBreakpoint,
	function()
		print("Breakpoint hook running!")
	end,
	"void(*)()",
	nil
)]]
M.crashHook =
	M.hook(
	signatures.CrashProc,
	function(original, err, arg)
		if arg == 0x1337 then
			M.on_breakpoint(context.get_context())
		elseif arg == 0x1338 then
			dbg.suspend_current_proc(context.get_context())
		elseif arg == 0x1339 then
			dbg.resume_suspended(context.get_context())
		else
			original(err, arg)
		end
	end,
	"void(*)(char*, int)",
	nil
)

function M.on_breakpoint()
end

function M.set_breakpoint_func(fn)
	M.on_breakpoint = fn
end

return M
