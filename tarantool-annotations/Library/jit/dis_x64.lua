---@meta

---# Builtin `jit.dis_x64` submodule
local jit_dis_x64 = {}

---Prints the x86-64 assembler code of a string of bytes.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> -- Disassemble hexadecimal 97 which is the x86-64 code for xchg eax, edi
--- ---
--- ...
---
--- tarantool> jit_dis_x64 = require('jit.dis_x64')
--- ---
--- ...
---
--- tarantool> jit_dis_64.disass('\x97')
--- 00000000  97                xchg eax, edi
--- ---
--- ...
--- ```
---
---For a list of available options, read [the source code of dis_x64.lua](https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/dis_x64.lua).
---
---@param code string
function jit_dis_x64.disass(code) end

return jit_dis_x64
