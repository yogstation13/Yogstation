--local dis = require "disassembler"
local signatures = require "signatures"
local ffi = require "ffi"
local M = {}

M.replaced_opcode = 0xDEAD
M.bytecode_len = 0
M.replaced_offset = 0

M.suspended_proc = nil
M.suspended_replaced_opcode = 0x1338

M.dmdis = ffi.load("dmdism")

function M.debug_hook(ctx)
	print(ctx.bytecode)
	print(ctx.current_opcode)
	M.dmdis.breakpoint_hit(ctx.bytecode, ctx.current_opcode)
end

function M.suspend_current_proc(ctx)
	print("Pausing proc")
	ctx.current_opcode = ctx.current_opcode + 1 --advance to next instruction so it resumes there
	M.suspended_proc = signatures.ResumeIn(ctx, 0x7fffff00)
	ctx.current_opcode = ctx.current_opcode - 1
	ctx.bytecode[ctx.current_opcode] = 0x00
	ctx.current_opcode = ctx.current_opcode - 1
	M.suspended_ctx = ctx
end

function M.resume_suspended(ctx)
	print("Resuming proc")
	M.suspended_proc.time_to_resume = 0
end

return M
