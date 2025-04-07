---@meta

---# Builtin `jit.v` submodule
local jit_v = {}

---Prints a trace of LuaJIT's progress compiling and interpreting code.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> -- Show what LuaJIT is doing for a Lua "for" loop
--- tarantool> jit_v = require('jit.v')
--- tarantool> jit_v.on()
--- tarantool> l = 0
--- tarantool> for i = 1, 1e6 do
---          >     l = l + i
---          > end
--- [TRACE   3 "for i = 1, 1e6 do
---     l = l + i
--- end":1 loop]
--- ---
--- ...
---
--- tarantool> print(l)
--- 500000500000
--- ---
--- ...
---
--- tarantool> jit_v.off()
--- ---
--- ...
--- ```
---
---For a list of available options, read [the source code of v.lua](https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/v.lua).
--- ```
---
---@param option string
---@param output_file string
function jit_v.on(option, output_file) end

---Disable printing a trace of LuaJIT's progress compiling and interpreting code.
function jit_v.off() end

return jit_v
