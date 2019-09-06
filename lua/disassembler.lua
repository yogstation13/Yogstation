local consts = require "defines"
local t2t = require "type2type"
local proc = require "proc"
local M = {}

function table.flatten(arr)
	local result = {}

	local function flatten(arr)
		for _, v in ipairs(arr) do
			if type(v) == "table" then
				flatten(v)
			else
				table.insert(result, v)
			end
		end
	end

	flatten(arr)
	return result
end

local xvar_magic_numbers = {
	[0xFFCD] = "USR",
	[0xFFCE] = "SRC",
	[0xFFCF] = "ARGS",
	[0xFFD0] = "DOT",
	[0xFFD9] = "ARG",
	[0xFFDA] = "LOCAL",
	[0xFFDB] = "GLOBAL",
	[0xFFDC] = "SUBVAR",
	[0xFFDD] = "CACHE",
	[0xFFDE] = "SRCPROC",
	[0xFFDF] = "PROC",
	[0xFFE5] = "WORLD",
	[0xFFE6] = "NULL"
}

local mnemonics = {
	[0x00] = "RETN", --return
	[0x01] = "NEW", --create new datum
	[0x03] = "OUTPUT", --output to something (<<)
	[0x0D] = "TEST", --test if top of stack is true and set test flag
	[0x0E] = "NOT", --logical negation
	[0x0F] = "JMP",
	[0x11] = "JZ", --jump if test flag is false
	[0x12] = "RET", --return value
	[0x1A] = "NLIST", --create new list
	[0x25] = "SPAWN", --pop value from stack and create "thread" after that many deciseconds, jump ahead arg1 opcodes and continue
	[0x29] = "CALL",
	[0x2A] = "CALLNR", --decref variables?
	[0x30] = "CALLGLOB", --call proc by id
	[0x33] = "GETVAR", --get variable by id and push
	[0x34] = "SETVAR", --pop and set variable by id
	[0x37] = "TEQ", --test equal
	[0x38] = "TNE", --test not equal
	[0x39] = "TL", --test lower
	[0x3A] = "TG", --test greater
	[0x3B] = "TLE", --test lower or equal
	[0x3C] = "TGE", --test greater or equal
	[0x3D] = "ANEG",
	[0x3E] = "ADD", --add two values
	[0x3F] = "SUB", --subtract two values
	[0x40] = "MUL",
	[0x41] = "DIV",
	[0x42] = "MOD",
	[0x43] = "ROUND",
	[0x44] = "ROUNDN",
	[0x45] = "ADDIP",
	[0x46] = "SUBIP",
	[0x50] = "PUSHI", --push integer
	[0x51] = "POP", --decrement value refcount
	[0x52] = "ITERLOAD",
	[0x53] = "ITERNEXT",
	[0x5B] = "LOCATE",
	[0x60] = "PUSHVAL", --push value
	[0x66] = "INC",
	[0x67] = "DEC",
	[0x7B] = "LISTGET",
	[0x7D] = "ISTYPE",
	[0x84] = "DBG FILE", --set context proc file field (debug mode only)
	[0x85] = "DBG LINENO", --set context line number (debug mode only)
	[0xB5] = "CALLOBJ",
	[0xBA] = "PROMPTCHECK",
	[0xC1] = "INPUT",
	[0xF8] = "JMP",
	[0xFA] = "JNZ",
	[0xFB] = "POP",
	[0xFC] = "CHECKNUM",
	[0x109] = "MD5",
	[0x1337] = "DBG BREAK" --invoke breakpoint handler (dreamland only)
}

local mnemonic_meta = {}
function mnemonic_meta.__index(self, key)
	return rawget(self, key) or "??? (" .. string.format("%x", key) .. ")"
end

mnemonics = setmetatable(mnemonics, mnemonic_meta)

local arg_counts = {
	[0x01] = 1,
	[0x0F] = 1,
	[0x11] = 1,
	[0x12] = 1,
	[0x1A] = 1,
	[0x25] = 1,
	[0x50] = 1,
	[0x52] = 2,
	[0x5B] = 1,
	[0x84] = 1,
	[0x85] = 1,
	[0xC1] = 3,
	[0xF8] = 1,
	[0xFA] = 1,
	[0xFB] = 1
}

function disassemble_procfile(bytecode, offset)
	return "", 1, {bytecode[offset + 1], "(" .. t2t.idx2str(bytecode[offset + 1]) .. ")"}
end

function subrange(t, first, len)
	local sub = {}
	for i = first, first + len - 1 do
		if not t[i] then
			break
		end
		sub[#sub + 1] = t[i]
	end
	return sub
end

function var_next(bytecode)
	local byte = table.remove(bytecode, 1)
	if not byte then
		return {"ERROR"}
	end
	if byte < 0xff00 then
		return {string.format("0x%x", byte)}
	end
	local sbyte = xvar_magic_numbers[byte]
	if sbyte == "LOCAL" then
		return {"LOCAL", tostring(table.remove(bytecode, 1))}
	elseif sbyte == "GLOBAL" then
		return {"GLOBAL", tostring(table.remove(bytecode, 1))}
	elseif sbyte == "SRC" then
		return {"SRC"}
	elseif sbyte == "USR" then
		return {"USR"}
	elseif sbyte == "SRCPROC" then
		return {"SRCPROC", tostring(table.remove(bytecode, 1))}
	elseif sbyte == "PROC" then
		return {"PROC", tostring(table.remove(bytecode, 1))}
	elseif sbyte == "WORLD" then
		return {"WORLD"}
	elseif sbyte == "CACHE" then
		return {"CACHE", var_next(bytecode)}
	elseif sbyte == "SUBVAR" then
		return {var_next(bytecode), "SUBVAR", var_next(bytecode)}
	elseif sbyte == "ARG" then
		return {"ARG", tostring(table.remove(bytecode, 1))}
	elseif sbyte == "NULL" then
		return {"NULL"}
	elseif sbyte == "ARGS" then
		return {"ARGS"}
	else
		error("UNIMPLEMENTED VAR ACCESS: 0x" .. string.format("%x", byte))
	end
end

function disassemble_var_read(bytecode, offset)
	local byte_copy = subrange(bytecode, offset + 1, 32)
	local derp = table.flatten(var_next(byte_copy))
	local pretty_printout = {}
	for k, v in ipairs(derp) do
		if string.sub(v, 1, 2) == "0x" then
			if derp[k - 1] == "CACHE" then
				table.insert(pretty_printout, "." .. t2t.idx2str(tonumber(v)))
			else
				table.insert(pretty_printout, t2t.idx2str(tonumber(v)))
			end
		elseif v == "SUBVAR" then
			table.insert(pretty_printout, ".")
		elseif v then
			table.insert(pretty_printout, v)
		end
	end
	return table.concat(derp, " "), #derp, {"(" .. table.concat(pretty_printout, "") .. ")"}
	--[[local gettype = xvar_magic_numbers[bytecode[offset + 1]\] or "CACHE"
	local arg_len = 2
	local arg_prettyprint = {}
	if gettype == "LOCAL" then
		arg_prettyprint = {bytecode[offset + 2]}
	elseif gettype == "WORLD" or gettype == "USR" or gettype == "SRC" then
		arg_len = 1
	elseif gettype == "SUBVAR" then
		local datumscope = xvar_magic_numbers[bytecode[offset + 2]\]
		if datumscope == "LOCAL" then
			arg_len = 4
			arg_prettyprint = {bytecode[offset + 3], bytecode[offset + 4], "(" .. t2t.idx2str(bytecode[offset + 4]) .. ")"}
		end
	elseif gettype == "NULL" then
		arg_len = 1
	elseif gettype == "CACHE" then
		arg_len = 3
		arg_prettyprint = {"(" .. t2t.idx2str(bytecode[offset + 1]) .. ")"}
	end
	return gettype, arg_len, arg_prettyprint]]
end

function disassemble_var_write(bytecode, offset)
	local t, l, p = disassemble_var_read(bytecode, offset)
	return t, l, p
end

function disassemble_pushval(bytecode, offset)
	local type = bytecode[offset + 1]
	local arg_len = 2
	local arg_prettyprint
	if type == consts.Number then
		arg_len = 3
	elseif type == consts.Null then
		arg_len = 2
	end
	if type == consts.String then
		return consts.types[type]:upper(), arg_len, {bytecode[offset + 2], "(" .. t2t.idx2str(bytecode[offset + 2]) .. ")"}
	end
	local t = consts.types[type] or "UNKNOWN_TYPE"
	return t:upper(), arg_len, {bytecode[offset + 2]}
end

function disassemble_datumcall(bytecode, offset)
	local srcsource = xvar_magic_numbers[bytecode[offset + 1]]
	if srcsource == "DATUM" then
		return "", 6, {
			xvar_magic_numbers[bytecode[offset + 2]],
			bytecode[offset + 3],
			bytecode[offset + 5],
			bytecode[offset + 6],
			"(" .. t2t.idx2str(bytecode[offset + 5]) .. ")"
		}
	elseif srcsource == "CACHE" then
		return srcsource, 3, {bytecode[offset + 2], bytecode[offset + 3], "(" .. t2t.idx2str(bytecode[offset + 2]) .. ")"}
	end
end

function disassemble_call(bytecode, offset)
	t, l, p = disassemble_var_read(bytecode, offset)
	table.insert(p, tostring(bytecode[offset + l + 1] .. " args"))
	return t, l + 1, p
end

function disassemble_global_call(bytecode, offset)
	params = {}
	for i = 1, bytecode[offset + 1] do
		table.insert(params, "param" .. i)
	end
	return "", 2, {proc.getProcById(bytecode[offset + 2]).path .. "(" .. table.concat(params, ", ") .. ")"}
end

local variable_argcount_disassemblers = {
	[0x29] = disassemble_call,
	[0x2A] = disassemble_call,
	[0x30] = disassemble_global_call,
	[0x33] = disassemble_var_read,
	[0x34] = disassemble_var_write,
	[0x60] = disassemble_pushval,
	[0x66] = disassemble_var_read,
	[0x67] = disassemble_var_read,
	[0x45] = disassemble_var_read,
	[0x46] = disassemble_var_read,
	[0x84] = disassemble_procfile
}

function M.test_disassemble()
	local bytecode = {0x50, 0x01, 0x34, 0xFFDA, 0x00, 0x00}
	M.disassemble(bytecode)
end

function M.disassemble(bytecode, bytecode_len, start_offset)
	local bytecode_len = bytecode_len or #bytecode
	local current_offset = start_offset or 0
	--for i = 0, bytecode_len do
	--	print(string.format("%x", bytecode[i]))
	--end
	local parseable_result = {}
	while current_offset < bytecode_len do
		local current_opcode = bytecode[current_offset]
		local mnemonic = mnemonics[current_opcode]
		local arg_count

		local vararg_dis = variable_argcount_disassemblers[current_opcode]
		if vararg_dis then
			mnemonic_mod, arg_count, pretty_args = vararg_dis(bytecode, current_offset)
			local out
			if mnemonic_mod then
				out = {
					BP = "",
					isCurrent = "",
					Offset = current_offset,
					Bytes = "",
					Mnemonic = mnemonic .. " " .. mnemonic_mod,
					Comment = table.concat(pretty_args or {}, " ")
				}
			else
				out = {
					BP = "",
					isCurrent = "",
					Offset = current_offset,
					Bytes = "",
					Mnemonic = mnemonic,
					Comment = table.concat(pretty_args or {}, " ")
				}
			end
			print(table.concat({out.Mnemonic, out.Comment}, " "))
			current_offset = current_offset + arg_count
			table.insert(parseable_result, out)
		else
			arg_count = arg_counts[current_opcode] or 0
			local pretty_args = {}
			for i = 1, arg_count do
				table.insert(pretty_args, bytecode[current_offset + i])
			end
			local out = {
				BP = "",
				isCurrent = "",
				Offset = current_offset,
				Bytes = "",
				Mnemonic = mnemonic,
				Comment = table.concat(pretty_args, " ")
			}
			print(table.concat({out.Mnemonic, out.Comment}, " "))
			current_offset = current_offset + arg_count
			table.insert(parseable_result, out)
		end
		current_offset = current_offset + 1
	end
	return parseable_result
end

function M.get_next_instruction_offset(bytecode, offset)
	local current_opcode = bytecode[offset]
	local vararg_dis = variable_argcount_disassemblers[current_opcode]
	if vararg_dis then
		mnemonic_mod, arg_count, pretty_args = vararg_dis(bytecode, offset)
		return offset + arg_count + 1
	else
		arg_count = arg_counts[current_opcode] or 0
		return offset + arg_count + 1
	end
end

return M
