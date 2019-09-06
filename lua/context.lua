local ffi = require("ffi")
local type2type = require "type2type"
local signatures = require "signatures"

local M = {}

local meta = {}
function M.get_context()
	return signatures.CurrentExecutionContext[0]
end

function meta.get_parent_context()
	local parent = ffi.cast("ExecutionContext*", self.parent_context)
	if parent ~= ffi.null then
		return parent[0]
	end
	return ffi.null
end

ffi.metatype("ExecutionContext", meta)

return M
