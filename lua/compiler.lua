local ffi = require "ffi"
local disasm = require "disassembler"
local consts = require "defines"
local t2t = require "type2type"
local proc = require "proc"
local M = {}

function M.link(bytecode, strings)
	print("Linking...")
	for _, s_info in ipairs(strings) do
		bytecode[s_info[2]] = t2t.toValue(ffi.string(s_info[1]), true).value
	end
	--[[for i = 0, compiled.function_names_len - 1 do
		print(ffi.string(compiled.function_names[i]))
		compiled.bytecode[compiled.call_positions[i]\] = proc.getProc("/proc/" .. ffi.string(compiled.function_names[i])).id
	end]]
	print("Linked successfully!")
end

function M.patch(proc_path, new_bytecode, strings, local_count)
	local p = proc.getProcSetupInfo(proc_path)
	bytecode = ffi.new("int[?]", #new_bytecode, new_bytecode)
	M.link(bytecode, strings)
	p.bytecode = bytecode
	p.bytecode_len = #new_bytecode
	p.local_var_count = local_count
end

return M

--[[ffi.cdef [[
	typedef struct CompiledCode {
		bool success;
		const char* error;
		unsigned int local_var_count;
		const char** strings;
		unsigned int* string_positions;
		unsigned int strings_len;
		unsigned int* call_positions;
		const char** function_names;
		unsigned int function_names_len;
		unsigned int* bytecode;
		unsigned int bytecode_len;
	} CompiledCode;

	CompiledCode* compile(const char* code);
]\]

print("\n")

local compiler = ffi.load("compiler5")

function M.compile(code)
	local compiled = compiler.compile(code)
	if not compiled.success then
		local err = ffi.string(compiled.error)
		print(err)
		proc.getProc("/proc/to_world")("<b><tt><font color='#FF0000'>COMPILATION ERROR:</font><tt></b>")
		proc.getProc("/proc/to_world")("<b><tt><font color='#FF0000'>" .. tostring(err) .. "</font><tt></b>")
		return nil
	end
	M.link(compiled)
	print("")
	print("Generated " .. tostring(compiled.bytecode_len) .. " bytes.")
	print(
		tostring(compiled.local_var_count) ..
			" local variables, " ..
				tostring(compiled.strings_len) .. " strings, " .. tostring(compiled.function_names_len) .. " procs to link."
	)
	print("")
	disasm.disassemble(compiled.bytecode, compiled.bytecode_len)
	print("disassembled")
	return compiled.bytecode
end

return M
]]
