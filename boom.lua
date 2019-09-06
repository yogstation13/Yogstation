package.path = package.path .. ";lua/?.lua;lua/?/init.lua"
print "byond init"
local byond = require "byond"
print "proc init"
local proc = require "proc"
local signatures = require "signatures"
print "loading datum"
require "datum"
print "loading list"
require "list"
print "loading t2t"
local t2t = require "type2type"
print "loading defines"
local consts = require "defines"
print "loading types"
local types = require "typepath"

local context = require "context"

local disasm = require "disassembler"

local T = byond.T

local ffi = require "ffi"

local compiler = require "compiler"

local json = require "json"

local debugger = require "debugger"
print "hooking!"

proc.getProc("/proc/get_sendmaps_time_raw"):hook(
	function(original, usr, src)
		return byond.sendmaps_time
	end
)

print("Hooked everything")