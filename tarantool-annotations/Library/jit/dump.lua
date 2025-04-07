---@meta

---# Builtin `jit.dump` submodule
local jit_dump = {}

---Prints the intermediate or machine code of the following Lua code.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> -- Show the machine code of a Lua "for" loop
--- tarantool> jit_dump = require('jit.dump')
--- tarantool> jit_dump.on('m')
--- tarantool> x = 0;
--- tarantool> for i = 1, 1e6 do
---          > x = x + i
---          > end
--- ---- TRACE 1 start 0x01047fbc38:1
--- ---- TRACE 1 mcode 148
--- 104c29f6b  mov dword [r14-0xed0], 0x1
--- 104c29f76  cvttsd2si ebp, [rdx]
--- 104c29f7a  rorx rbx, [rdx-0x10], 0x2f
--- 104c29f81  shr rbx, 0x11
--- 104c29f85  mov rdx, [rbx+0x10]
--- 104c29f89  cmp dword [rdx+0x34], +0x3f
--- 104c29f8d  jnz 0x104c1a010  ->0
--- 104c29f93  mov rcx, [rdx+0x28]
--- 104c29f97  mov rdi, 0xfffd8001046b3d58
--- 104c29fa1  cmp rdi, [rcx+0x320]
--- 104c29fa8  jnz 0x104c1a010  ->0
--- 104c29fae  lea rax, [rcx+0x318]
--- 104c29fb5  cmp dword [rax+0x4], 0xfff90000
--- 104c29fbc  jnb 0x104c1a010  ->0
--- 104c29fc2  xorps xmm7, xmm7
--- 104c29fc5  cvtsi2sd xmm7, ebp
--- 104c29fc9  addsd xmm7, [rax]
--- 104c29fcd  movsd [rax], xmm7
--- 104c29fd1  add ebp, +0x01
--- 104c29fd4  cmp ebp, 0x000f4240
--- 104c29fda  jg 0x104c1a014   ->1
--- ->LOOP:
--- 104c29fe0  xorps xmm6, xmm6
--- 104c29fe3  cvtsi2sd xmm6, ebp
--- 104c29fe7  addsd xmm7, xmm6
--- 104c29feb  movsd [rax], xmm7
--- 104c29fef  add ebp, +0x01
--- 104c29ff2  cmp ebp, 0x000f4240
--- 104c29ff8  jle 0x104c29fe0  ->LOOP
--- 104c29ffa  jmp 0x104c1a01c  ->3
--- ---- TRACE 1 stop -> loop
---
--- ---
--- ...
---
--- tarantool> print(x)
--- 500000500000
--- ---
--- ...
---
--- tarantool> jit_dump.off()
--- ---
--- ...
--- ```
---
---For a list of available options, read [the source code of dump.lua](https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/dump.lua).
---
---@param option string
---@param output_file string
function jit_dump.on(option, output_file) end

---Disable printing the intermediate or machine code of the following Lua code.
---
---@see jit.dump.on
function jit_dump.off() end

return jit_dump
