---@meta

local json = {}

---@class json.cfg
---@field encode_max_depth? number (default: 128) Max recursion depth for encoding
---@field encode_deep_as_nil? boolean (default: false) A flag saying whether to crop tables with nesting level deeper than cfg.encode_max_depth. Not-encoded fields are replaced with one null. If not set, too deep nesting is considered an error.
---@field encode_invalid_numbers? boolean (default: true) A flag saying whether to enable encoding of NaN and Inf numbers
---@field encode_number_precision? number (default: 14) Precision of floating point numbers
---@field encode_load_metatables? boolean (default: true) A flag saying whether the serializer will follow __serialize metatable field
---@field encode_use_tostring? boolean (default: false) A flag saying whether to use tostring() for unknown types
---@field encode_invalid_as_nil? boolean (default: false) A flag saying whether use NULL for non-recognized types
---@field encode_sparse_convert? boolean (default: true) A flag saying whether to handle excessively sparse arrays as maps. See detailed description below.
---@field encode_sparse_ratio? number (default: 2) 1/encode_sparse_ratio is the permissible percentage of missing values in a sparse array.
---@field encode_sparse_safe? number (default: 10) A limit ensuring that small Lua arrays are always encoded as sparse arrays (instead of generating an error or encoding as a map)
---@field decode_invalid_numbers? boolean (default: true) A flag saying whether to enable decoding of NaN and Inf numbers
---@field decode_save_metatables? boolean (default: true) A flag saying whether to set metatables for all arrays and maps
---@field decode_max_depth? number (default: 128) Max recursion depth for decoding

---Set values that affect the behavior of `json.encode` and `json.decode`
---
---The values are all either integers or boolean `true`/`false`.
---
---@param cfg json.cfg
function json.cfg(cfg) end

---Convert a Lua object to a JSON string.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> json.encode(setmetatable({'A', 'B'}, { __serialize="seq"}))
--- ---
--- - '["A","B"]'
--- ...
--- tarantool> json.encode(setmetatable({'A', 'B'}, { __serialize="map"}))
--- ---
--- - '{"1":"A","2":"B"}'
--- ...
--- tarantool> json.encode({setmetatable({f1 = 'A', f2 = 'B'}, { __serialize="map"})})
--- ---
--- - '[{"f2":"B","f1":"A"}]'
--- ...
--- tarantool> json.encode({setmetatable({f1 = 'A', f2 = 'B'}, { __serialize="seq"})})
--- ---
--- - '[[]]'
--- ...
--- ```
---
---@param value any either a scalar value or a Lua table value
---@param cfg? json.cfg configuration
---@return string
function json.encode(value, cfg) end

---Convert a JSON string to a Lua object.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> json = require('json')
--- ---
--- ...
--- tarantool> json.decode('123')
--- ---
--- - 123
--- ...
--- tarantool> json.decode('[123, "hello"]')
--- ---
--- - [123, 'hello']
--- ...
--- tarantool> json.decode('{"hello": "world"}').hello
--- ---
--- - world
--- ...
--- ```
---
--- See the tutorial [`Sum a JSON field for all tuples`](doc://c_lua_tutorial-sum_a_json_field>) to see how `json.decode()` can fit in an application.
---
---@param str string a string formatted as JSON
---@param cfg? json.cfg configuration
---@return any
function json.decode(str, cfg) end

---A value comparable to Lua "nil" which may be useful as a placeholder in a tuple.
json.NULL = box.NULL

return json
