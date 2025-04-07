---@meta

---# Builtin `jit.bc` submodule
local jit_bc = {}

---Prints the byte code of a function.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> jit_bc = require('jit.bc')
--- ---
--- ...
---
--- tarantool> function f()
---          > print("D")
---          > end
--- ---
--- ...
---
--- tarantool> jit_bc.dump(f)
--- -- BYTECODE -- 0x01113163c8:1-3
--- 0001    GGET     0   0      ; "print"
--- 0002    KSTR     2   1      ; "D"
--- 0003    CALL     0   1   2
--- 0004    RET0     0   1
---
--- ---
--- ...
---
--- ```
---
--- ```lua
--- function f()
---   print("D")
--- end
--- require('jit.bc').dump(f)
--- ```
---
---For a list of available options, read [the source code of bc.lua](https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/bc.lua).
---
---@param f function
function jit_bc.dump(f) end

return jit_bc
