---@meta

-- TODO: need generic inheritance to inherit from `T & U`.

---@class box.tuple<T, U>: table
local tuple_object = {}

---Number of bytes in the tuple.
---
---If `t` is a tuple instance, `t:bsize()` will return the number of bytes in the tuple.
---
---With both the memtx storage engine and the vinyl storage engine the default maximum is one megabyte ([`memtx_max_tuple_size`](lua://cfg_storage-memtx_max_tuple_size) or [`vinyl_max_tuple_size`](cfg_storage-vinyl_max_tuple_size))
---
---Every field has one or more "length" bytes preceding the actual contents, so `bsize()` returns a value which is slightly greater than the sum of the lengths of the contents.
---
---The value does not include the size of "struct tuple" (for the current size of this structure look in the [tuple.h](https://github.com/tarantool/tarantool/blob/1.10/src/box/tuple.h) file in Tarantool's source code).
---
---**Example:**
---
---In the following example, a tuple named `t` is created which has three fields, and for each field it takes one byte to store the length and three bytes to store the contents, and then there is one more byte to store a count of the number of fields, so `bsize()` returns `3*(1+3)+1`. This is the same as the size of the string that `msgpack.encode({'aaa','bbb','ccc'})` would return.
---
--- ```tarantoolsession
--- tarantool> t = box.tuple.new{'aaa', 'bbb', 'ccc'}
--- ---
--- ...
--- tarantool> t:bsize()
--- ---
--- - 13
--- ...
--- ```
---
---@return number bytes
function tuple_object:bsize() end

---Find index of a value in the tuple
---
---If `t` is a tuple instance, `t:find(search-value)` returns the number of the first field in `t` that matches the search value, and `t:findall(search-value [, search-value ...])` returns numbers of all fields in `t` that match the search value. Optionally one can put a numeric argument `field-number` before the search-value to indicate "start searching at field number `field-number`".
---
---**Example:**
---
---In the following example, a tuple named `t` is created and then: the number of the first field in `t` which matches 'a' is returned, then the numbers of all the fields in `t` which match 'a' are returned, then the numbers of all the fields in t which match 'a' and are at or after the second field are returned.
---
--- ```tarantoolsession
--- tarantool> t = box.tuple.new{'a', 'b', 'c', 'a'}
--- ---
--- ...
--- tarantool> t:find('a')
--- ---
--- - 1
--- ...
--- tarantool> t:findall('a')
--- ---
--- - 1
--- - 4
--- ...
--- tarantool> t:findall(2, 'a')
--- ---
--- - 4
--- ...
--- ```
---
---@param field_number_or_search_value? number
---@param search_value? any
---@return number
function tuple_object:find(field_number_or_search_value, search_value) end

---Find all indices of a value in the tuple
---
---If `t` is a tuple instance, `t:find(search-value)` returns the number of the first field in `t` that matches the search value, and `t:findall(search-value [, search-value ...])` returns numbers of all fields in `t` that match the search value. Optionally one can put a numeric argument `field-number` before the search-value to indicate "start searching at field number `field-number`".
---
---**Example:**
---
---In the following example, a tuple named `t` is created and then: the number of the first field in `t` which matches 'a' is returned, then the numbers of all the fields in `t` which match 'a' are returned, then the numbers of all the fields in t which match 'a' and are at or after the second field are returned.
---
--- ```tarantoolsession
--- tarantool> t = box.tuple.new{'a', 'b', 'c', 'a'}
--- ---
--- ...
--- tarantool> t:find('a')
--- ---
--- - 1
--- ...
--- tarantool> t:findall('a')
--- ---
--- - 1
--- - 4
--- ...
--- tarantool> t:findall(2, 'a')
--- ---
--- - 4
--- ...
--- ```
---
---@param field_number_or_search_value? number
---@param search_value? any
---@return number[]
function tuple_object:findall(field_number_or_search_value, search_value) end

---Lua `next()` function, but for a tuple object.
---
---When called without arguments, `tuple:next()` returns the first field from a tuple. Otherwise, it returns the field next to the indicated position.
---
---However `tuple:next()` is not really efficient, and it is better to use [`tuple:pairs()/ipairs()`](lua://box.tuple.pairs).
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> tuple = box.tuple.new({5, 4, 3, 2, 0})
--- ---
--- ...
---
--- tarantool> tuple:next()
--- ---
--- - 1
--- - 5
--- ...
---
--- tarantool> tuple:next(1)
--- ---
--- - 2
--- - 4
--- ...
---
--- tarantool> ctx, field = tuple:next()
--- ---
--- ...
---
--- tarantool> while field do
--- > print(field)
--- > ctx, field = tuple:next(ctx)
--- > end
--- 5
--- 4
--- 3
--- 2
--- 0
--- ---
--- ...
--- ```
---
---@see box.tuple.pairs
---@see box.tuple.ipairs
---
---@param pos? number
---@return number field_number, any value
function tuple_object:next(pos) end

---Get a tuple iterator
---
---In Lua, [`lua-table-value:pairs()`](https://www.lua.org/pil/7.3.html) is a method which returns: `function`, `lua-table-value`, `nil`.
---
---Tarantool has extended this so that `tuple-value:pairs()` returns: `function`, `tuple-value`, `nil`. It is useful for Lua iterators, because Lua iterators traverse a value's components until an end marker is reached.
---
---`tuple_object:ipairs()` is the same as `pairs()`, because tuple fields are always integers.
---
---In the following example, a tuple named `t` is created and then all its fields are selected using a Lua for-end loop.
---
--- ```tarantoolsession
--- tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
--- ---
--- ...
--- tarantool> tmp = ''
--- ---
--- ...
--- tarantool> for k, v in t:pairs() do
--- >   tmp = tmp .. v
--- > end
--- ---
--- ...
--- tarantool> tmp
--- ---
--- - Fld#1Fld#2Fld#3Fld#4Fld#5
--- ...
--- ```
---
---@see box.tuple.ipairs
---
---@return fun() ctx, any tuple_value, nil
function tuple_object:pairs() end

---Get a tuple iterator
---
---In Lua, [`lua-table-value:pairs()`](https://www.lua.org/pil/7.3.html) is a method which returns: `function`, `lua-table-value`, `nil`.
---
---Tarantool has extended this so that `tuple-value:pairs()` returns: `function`, `tuple-value`, `nil`. It is useful for Lua iterators, because Lua iterators traverse a value's components until an end marker is reached.
---
---`tuple_object:ipairs()` is the same as `pairs()`, because tuple fields are always integers.
---
---In the following example, a tuple named `t` is created and then all its fields are selected using a Lua for-end loop.
---
--- ```tarantoolsession
--- tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
--- ---
--- ...
--- tarantool> tmp = ''
--- ---
--- ...
--- tarantool> for k, v in t:pairs() do
--- >   tmp = tmp .. v
--- > end
--- ---
--- ...
--- tarantool> tmp
--- ---
--- - Fld#1Fld#2Fld#3Fld#4Fld#5
--- ...
--- ```
---
---@see box.tuple.pairs
---
---@return fun() ctx, any tuple_value, nil
function tuple_object:ipairs() end

---If t is a tuple instance, `t:totable()` will return all fields, `t:totable(1)` will return all fields starting with field number 1, t:totable(1,5) will return all fields between field number 1 and field number 5.
---It is preferable to use t:totable() rather than t:unpack().
---
---@param start_field_number? number
---@param end_field_number? number
---@return any[]
function tuple_object:totable(start_field_number, end_field_number) end

-- TODO: Extend generic support to allow inferring tomap() type better.

---The `tuple_object:totable()` function only returns a table containing the values. But the `tuple_object:tomap()` function returns a table containing not only the values, but also the key:value pairs.
---
---This only works if the tuple comes from a space that has been formatted with a format clause.
---
---@param options? { names_only: boolean }
---@return T & U
function tuple_object:tomap(options) end

---Update a tuple.
---
---This function updates a tuple which is not in a space. Compare the function [`box.space.<space-name>:update(<key>, {{<format>, <field_no>, <value>}}, ...})`](lua://box.space.update) which updates a tuple in a space.
---
---For details: see the description for `operator`, `field_no`, and `value` in the section :ref:`box.space.space-name:update{key, format,
---{field_number, value}...) <box_space-update>`.
---
---If the original tuple comes from a space that has been formatted with a [format clause](lua://box.space.format), the formatting will be preserved for the result tuple.
---
---In the following example, a tuple named `t` is created and then its second field is updated to equal 'B'.
---
--- ```tarantoolsession
--- tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
--- ---
--- ...
--- tarantool> t:update({{'=', 2, 'B'}})
--- ---
--- - ['Fld#1', 'B', 'Fld#3', 'Fld#4', 'Fld#5']
--- ...
--- ```
---
---*Since 2.3* a tuple can also be updated via [JSON paths](json.paths).
---
---@param update_operations [box.update_operation, number|string, tuple_type][]
---@return box.tuple
function tuple_object:update(update_operations) end

---Get information about the tuple memory usage.
---
---**Note:** `waste_size` is provided for reference only and can be inaccurate. Avoid using it for memory usage calculations.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> box.space.tester:get('222200000'):info()
--- ---
--- - data_size: 55
--- waste_size: 95
--- arena: memtx
--- field_map_size: 4
--- header_size: 6
--- ...
--- ```
---
---@return {
---     data_size: number,
---     header_size: number,
---     field_map_size: number,
---     waste_size: number,
---     arena: 'memtx' | 'malloc' | 'runtime'
---}
function tuple_object:info() end

---# Builtin `box.tuple` submodule
---
---The `box.tuple` submodule provides read-only access for the `tuple` userdata type. It allows, for a single [tuple](lua://box.tuple): selective retrieval of the field contents, retrieval of information about size, iteration over all the fields, and conversion to a [Lua table](https://www.lua.org/pil/2.5.html).
---
---**How to convert tuples to/from Lua tables:**
---
---This function illustrates how to convert tuples to/from Lua tables and lists of scalars:
---
--- ```lua
--- tuple = box.tuple.new({scalar1, scalar2, ... scalar_n}) -- scalars to tuple
--- lua_table = {tuple:unpack()}                            -- tuple to Lua table
--- lua_table = tuple:totable()                             -- tuple to Lua table
--- scalar1, scalar2, ... scalar_n = tuple:unpack()         -- tuple to scalars
--- tuple = box.tuple.new(lua_table)                        -- Lua table to tuple
--- ```
---
---Then it will find the field that contains 'b', remove that field from the tuple,
---and display how many bytes remain in the tuple. The function uses Tarantool
---`box.tuple` functions `new()`, `unpack()`, `find()`, `transform()`,
---`bsize()`.
---
--- ```lua
--- function example()
---     local tuple1, tuple2, lua_table_1, scalar1, scalar2, scalar3, field_number
---     local luatable1 = {}
---     tuple1 = box.tuple.new({'a', 'b', 'c'})
---     luatable1 = tuple1:totable()
---     scalar1, scalar2, scalar3 = tuple1:unpack()
---     tuple2 = box.tuple.new(luatable1[1],luatable1[2],luatable1[3])
---     field_number = tuple2:find('b')
---     tuple2 = tuple2:transform(field_number, 1)
---     return 'tuple2 = ' , tuple2 , ' # of bytes = ' , tuple2:bsize()
--- end
--- ```
---
---... And here is what happens when one invokes the function:
---
--- ```tarantoolsession
--- tarantool> example()
--- ---
--- - tuple2 =
--- - ['a', 'c']
--- - ' # of bytes = '
--- - 5
--- ...
--- ```
box.tuple = {}

---Construct a new tuple from either a scalar or a Lua table.
---
---Alternatively, one can get new tuples from Tarantool's [`select`](lua://box.space.select) or [`insert`](lua://box.space.insert) or [`replace`](box.space.replace) or [`update`](box.space.update) requests, which can be regarded as statements that do `new()` implicitly.
---
---**Example:**
---
---In the following example, `x` will be a new table object containing one tuple and `t` will be a new tuple object. Saying `t` returns the entire tuple `t`.
---
--- ```tarantoolsession
--- tarantool> x = box.space.tester:insert{
--- >   33,
--- >   tonumber('1'),
--- >   tonumber64('2')
--- > }:totable()
--- ---
--- ...
--- tarantool> t = box.tuple.new{'abc', 'def', 'ghi', 'abc'}
--- ---
--- ...
--- tarantool> t
--- ---
--- - ['abc', 'def', 'ghi', 'abc']
--- ...
--- ```
---
---@overload fun(...: tuple_type): box.tuple<any, any>
---@param value tuple_type[]
---@param options? { format?: box.tuple.format|box.tuple.field_format[] }
---@return box.tuple<any, any> tuple
function box.tuple.new(value, options) end

---Check whether a given object is a tuple cdata object.
---
---*Since 2.2.3, 2.3.2, and 2.4.1*
---
---Never raises nor returns an error.
---
---@param object any
---@return boolean is_tuple returns true if given object is box.tuple
function box.tuple.is(object) end

---# Builtin `box.tuple.format` submodule
box.tuple.format = {}

---Tuple format.
---
---@class box.tuple.format: userdata
local tuple_format = {}

---@alias box.tuple.field_format box.space.field_format

---Returns tuple format as a lua table.
---
---@return box.tuple.field_format[]
function tuple_format:totable() end

---Get a tuple_format iterator.
---
---In Lua, [`lua-table-value:pairs()`](https://www.lua.org/pil/7.3.html) is a method which returns: `function`, `lua-table-value`, `nil`.
---
---Tarantool has extended this so that `tuple_format:pairs()` returns: `function`, `tuple_format_field`, `nil`. It is useful for Lua iterators, because Lua iterators traverse a value's components until an end marker is reached.
---
---`tuple_format:ipairs()` is the same as `pairs()`, because tuple_format fields are always integers.
---
---@see box.tuple.format.ipairs
---@return fun(tbl: any): (integer, box.tuple.field_format)
function tuple_format:pairs() end

---@see box.tuple.format.pairs
tuple_format.ipairs = tuple_format.pairs

---Get the format of a tuple.
---
---The resulting table lists the fields of a tuple (their names and types) if the format option was specified during the tuple creation. Otherwise, empty table is returned.
---
---@return box.tuple.field_format[] # the tuple format.
function tuple_object:format() end

---Create a new tuple format.
---@param tuple_format box.tuple.field_format[]
---@return box.tuple.format
function box.tuple.format.new(tuple_format) end

---Check whether a given object is a tuple_format userdata object.
---@param object any
---@return boolean is_tuple_format returns true if given object is box.tuple.format
function box.tuple.format.is(object) end
