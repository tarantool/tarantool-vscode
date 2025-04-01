---@meta

---@class box.error: ffi.cdata*
---@field type string The error type (usually ClientError).
---@field base_type string The base type (usually ClientError).
---@field code number Number of error.
---@field prev? box.error *Since 2.4.1* The previous error for the current one.
---@field message any The error message.
---@field reason string *Since 2.10.0* Returns the `box.info.ro_reason` value at the moment of throwing the `box.error.READONLY` error.
---@field errno? number If the error is a system error (for example, a socket or file IO failure), a C standard error number.
---@field state? string For the box.error.READONLY error, returns the current state of a replica set node in regards to leader election (see [`box.info.election.state`](lua://box.info.election.state)).
local box_error_object = {}

---# Builtin `box.error` submodule.
---
---The `box.error` submodule can be used to work with errors in your application.
---
---For example, you can get the information about the last error raised by Tarantool or raise custom errors manually.
---
---The difference between raising an error using `box.error` and a Lua's built-in [error](https://www.lua.org/pil/8.3.html) function is that when the error reaches the client, its error code is preserved.
---
---In contrast, a Lua error would always be presented to the client as `ER_PROC_LUA`.
---
---**Note:**
---
---To learn how to handle errors in your application, see the [handling errors](doc://error_handling) section.
---
---When called without arguments, box.error() re-throws whatever the last error was.
---@overload fun(): box.error
box.error = {}

---Throw an error. When called with a Lua-table argument, the code and reason have any user-desired values. The result will be those values.
---
---@param err { reason: string, code: number? } reason is description of an error, defined by user; code is numeric code for this error, defined by user
---@return box.error
function box.error(err) end

---Throw an error. This method emulates a request error, with text based on one of the pre-defined Tarantool errors defined in the file errcode.h in the source tree.
---@param code number number of a pre-defined error
---@param errtext string part of the message which will accompany the error
---@param ... string part of the message which will accompany the error
function box.error(code, errtext, ...) end

---@class box.error.trace
---@field file string Tarantool source file
---@field line number Tarantool source file line number

---@class box.error.table
---@field code number error's number
---@field type string error's C++ class
---@field message string error's message
---@field prev? box.error previous error
---@field base_type string usually ClientError or CustomError
---@field custom_type string? present if custom ErrorType was passed
---@field trace box.error.trace[]? backtrace

---Get error details that may include an error code, type, message, and trace.
---
---@return box.error.table
function box_error_object:unpack() end

---Raise the current error.
function box_error_object:raise() end

---Create an error object with the specified parameters.
---
---**Examples:**
---
--- ```lua
--- local custom_error = box.error.new({ code = 500,
---                                      reason = 'Internal server error' })
---
--- box.error(custom_error)
--- --[[
--- ---
--- - error: Internal server error
--- ...
--- --]]
--- ```
---
--- ```lua
--- local custom_error = box.error.new({ code = 500,
---                                      reason = 'Internal server error',
---                                      type = 'CustomInternalError' })
---
--- box.error(custom_error)
--- --[[
--- ---
--- - error: Internal server error
--- ...
--- --]]
--- ```
---
--- ```lua
--- local custom_error = box.error.new('CustomInternalError', 'Internal server error')
---
--- box.error(custom_error)
--- --[[
--- ---
--- - error: Internal server error
--- ...
--- --]]
--- ```
---
--- ```lua
--- local custom_error = box.error.new(box.error.NO_SUCH_USER, 'John')
---
--- box.error(custom_error)
--- --[[
--- ---
--- - error: User 'John' is not found
--- ...
--- --]]
--- ```
---
--- ```lua
--- local custom_error = box.error.new(box.error.CREATE_SPACE, 'my_space', 'the space already exists')
---
--- box.error(custom_error)
--- --[[
--- ---
--- - error: 'Failed to create space ''my_space'': the space already exists'
--- ...
--- --]]
--- ```
---
---@param err { reason: string, code: number?, type: string? } custom error
---@return box.error
---@overload fun(code: number, errtxt: string): box.error
---@overload fun(type: string, reason: string, ...): box.error
function box.error.new(err) end

---Get the last error that was raised.
---
---@return box.error
function box.error.last() end
