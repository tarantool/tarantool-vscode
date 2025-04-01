---@meta

---@alias integer64 ffi.cdata*
---@alias float64 ffi.cdata*

---@alias scalar
---| nil # box.NULL or Lua nil
---| boolean # true/false
---| string # lua string
---| integer # lua number
---| integer64 # luajit cdata
---| number # lua number
---| float64 # luajit cdata
---| decimal # Tarantool decimal
---| datetime # Tarantool datetime
---| interval # Tarantool interval
---| uuid # Tarantool uuid

---@alias compound
---| map # Tarantool map
---| array # Tarantool arr

---@alias tuple_type scalar | compound
---@alias tuple_type_name 'unsigned' | 'string' | 'boolean' | 'number' | 'integer' | 'decimal' | 'varbinary' | 'uuid' | 'scalar' | 'array'

---@alias map table<string, tuple_type> Tarantool kv map, keys are always strings
---@alias array tuple_type[] Tarantool array

---Convert a string or a Lua number to a 64-bit integer.
---
---@param value string|number
---@return ffi.cdata*|number
function tonumber64(value) end

---Allocates a new Lua table.
---
---@param narr number
---@param nrec number
---@return table
function table.new(narr, nrec) end

---Perform a deep copy of the table
---
---Return a "deep" copy of the table -- a copy which follows nested structures to any depth and does not depend on pointers, it copies the contents.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> input_table = {1,{'a','b'}}
--- ---
--- ...
---
--- tarantool> output_table = table.deepcopy(input_table)
--- ---
--- ...
---
--- tarantool> output_table
--- ---
--- - - 1
--- - - a
--- - b
--- ...
--- ```
---
---@param t table
---@return table
function table.deepcopy(t) end

---Perform a shallow copy of the table
---
---@see table.deepcopy
---
---@param t table
---@return table
function table.copy(t) end

---Removes all keys from table.
---
---@param t table
function table.clear(t) end

---Constant `box.NULL`
---
---There are some major problems with using Lua `nil` values in tables. For example: you can't correctly assess the length of a table that is not a sequence. (Learn more about data types in [Lua](https://www.lua.org/manual/5.1/manual.html#2.2) and [LuaJIT](http://luajit.org/ext_ffi_semantics.html))
---
--- ```tarantoolsession
--- tarantool> t = {0, nil, 1, 2, nil}
--- ---
--- ...
---
--- tarantool> t
--- ---
--- - - 0
--- - null
--- - 1
--- - 2
--- ...
---
--- tarantool> #t
--- ---
--- - 4
--- ...
---
--- ```
---
---The console output of `t` processes `nil` values in the middle and at the end of the table differently. This is due to undefined behavior.
---
---**Note:** Trying to find the length for sparse arrays in LuaJIT leads to another scenario of [undefined behavior](https://www.lua.org/manual/5.1/manual.html#2.5.5). To avoid this problem, use Tarantool's `box.NULL` constant instead of `nil`. `box.NULL` is a placeholder for a `nil` value in tables to preserve a key without a value.
---
---**Using `box.NULL`:**
---
---`box.NULL` is a value of the [cdata](http://luajit.org/ext_ffi_semantics.html) type representing a NULL pointer. It is similar to `msgpack.NULL`, `json.NULL` and `yaml.NULL`. So it is some not `nil` value, even if it is a pointer to NULL.
---
---Use `box.NULL` only with capitalized NULL (`box.null` is incorrect).
---
---**Note:** Technically speaking, `box.NULL` equals to `ffi.cast('void *', 0)`.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> t = {0, box.NULL, 1, 2, box.NULL}
--- ---
--- ...
---
--- tarantool> t
--- ---
--- - - 0
--- - null # cdata
--- - 1
--- - 2
--- - null # cdata
--- ...
---
--- tarantool> #t
--- ---
--- - 5
--- ...
---
--- ```
---
---**Note:** Notice that `t[2]` shows the same `null` output in both examples. However in this example `t[2]` and `t[5]` are of the cdata type, while in the previous example their type was `nil`.
---
---**Important:**
---
---Avoid using implicit comparisons with nullable values when using `box.NULL`. Due to [Lua behavior](https://www.lua.org/manual/5.1/manual.html#2.4.4) returning anything except `false` or `nil` from a condition expression is considered as `true`. And, as it was mentioned earlier, `box.NULL` is a pointer by design.
---
---That is why the expression `box.NULL` will always be considered `true` in case it is used as a condition in a comparison. This means that the code
---
---`if box.NULL then func() end`
---
---will always execute the function `func()` (because the condition `box.NULL` will always be neither `false` nor `nil`).
---
---**Distinction of `nil` and `box.NULL`:**
---
---Use the expression `if x == nil` to check if the `x` is either a `nil` or a `box.NULL`.
---
---To check whether `x` is a **nil** but not a `box.NULL`, use the following condition expression:
---
--- ```lua
--- type(x) == 'nil'
--- ```
---
---If it's `true`, then `x` is a `nil`, but not a `box.NULL`.
---
---You can use the following for `box.NULL`:
---
--- ```lua
---
--- x == nil and type(x) == 'cdata'
---
--- ```
---
---If the expression above is **true**, then `x` is a `box.NULL`.
---
---**Note:**
---
---By converting data to different formats (JSON, YAML, msgpack), you shall expect that it is possible that **nil** in sparse arrays will be converted to `box.NULL`. And it is worth mentioning that such conversion might be unexpected (for example: by sending data via :ref:`net.box <net_box-module> or by obtaining data from [`spaces`](box.space) etc.).
---
--- ```tarantoolsession
--- tarantool> type(({1, nil, 2})[2])
--- ---
--- - nil
--- ...
---
--- tarantool> type(json.decode(json.encode({1, nil, 2}))[2])
--- ---
--- - cdata
--- ...
--- ```
---
--- You must anticipate such behavior and use a proper condition expression. Use the explicit comparison `x == nil` for checking for NULL in nullable values. It will detect both **nil** and `box.NULL`.
---
---@type ffi.cdata*
box.NULL = {}

box.NULL

---Parse and execute an arbitrary chunk of Lua code. This function is mainly useful to define and run Lua code without having to introduce changes to the global Lua environment.
---
---@param lua_chunk_string string Lua code
---@param ... any zero or more scalar values which will be appended to
---@return any ... whatever is returned by the Lua code chunk.
function dostring(lua_chunk_string, ...) end

---@class int64_t: ffi.cdata*
---@operator add(int64_t|number): int64_t
---@operator sub(int64_t|number): int64_t
---@operator mul(int64_t|number): int64_t
---@operator div(int64_t|number): int64_t
---@operator unm: int64_t
---@operator mod(int64_t|number): int64_t
---@operator pow(int64_t|number): int64_t

---@class uint64_t: ffi.cdata*
---@operator add(int64_t|number|uint64_t): uint64_t
---@operator sub(int64_t|number|uint64_t): uint64_t
---@operator mul(int64_t|number|uint64_t): uint64_t
---@operator div(int64_t|number|uint64_t): uint64_t
---@operator unm: uint64_t
---@operator mod(int64_t|number|uint64_t): uint64_t
---@operator pow(int64_t|number|uint64_t): uint64_t

---Returns path of the library.
---
---@param name string
---@return string
function package.search(name) end

---Sets root for require.
---
---@param path ?string
function package.setsearchroot(path) end

---@type any
_TARANTOOL = {}
