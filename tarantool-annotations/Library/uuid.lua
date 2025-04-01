---@meta

---# Builtin `uuid` module
---
---A "UUID" is a [Universally unique identifier](https://en.wikipedia.org/wiki/Universally_unique_identifier).
---
---If an application requires that a value be unique only within a single computer or on a single database, then a simple counter is better than a UUID, because getting a UUID is time-consuming (it requires a [syscall](https://en.wikipedia.org/wiki/Syscall)). For clusters of computers, or widely distributed applications, UUIDs are better.
---
---Tarantool generates UUIDs following the rules for RFC 4122 [version 4 variant 1](https://en.wikipedia.org/wiki/Universally_unique_identifier#Versio4_(random)).
local uuid = {}

---@class uuid: ffi.cdata*
local uuid_obj = {}

---Create a UUID sequence. You can use it in an index over a uuid field.
---
---*Since 2.4.1*
---
---For example, to create such index for a space named `test`, say:
---
--- ```tarantoolsession
--- tarantool> box.space.test:create_index("pk", {parts={{field = 1, type = 'uuid'}}})
--- ```
---
---Now you can insert UUIDs into the space:
---
--- ```tarantoolsession
--- tarantool> box.space.test:insert{uuid.new()}
--- ---
--- - [e631fdcc-0e8a-4d2f-83fd-b0ce6762b13f]
--- ...
---
--- tarantool> box.space.test:insert{uuid.fromstr('64d22e4d-ac92-4a23-899a-e59f34af5479')}
--- ---
--- - [64d22e4d-ac92-4a23-899a-e59f34af5479]
--- ...
---
--- tarantool> box.space.test:select{}
--- ---
--- - - [64d22e4d-ac92-4a23-899a-e59f34af5479]
--- - [e631fdcc-0e8a-4d2f-83fd-b0ce6762b13f]
--- ...
--- ```
---
---@return uuid
function uuid.new() end

---@alias uuid.byte_order
---| "l" # little-endian
---| "b" # big-endian
---| "h" # host (endianness depends on host)
---| "n" # network (endianness depends on network)
---| "host" # host (endianness depends on host)
---| "network" # network (endianness depends on network)

---Get UUID as 16-byte string.
---
---@param byte_order? uuid.byte_order Byte order of the resulting UUID
---@return string uuid 16-byte string
function uuid.bin(byte_order) end

---Convert UUID to a 16-byte string.
---
---@param byte_order? uuid.byte_order Byte order of the resulting UUID
---@return string uuid 16-byte string
function uuid_obj:bin(byte_order) end

---Get UUID as 36-byte hexademical string.
---
---@return string uuid 36-byte binary string
function uuid.str() end

---Convert UUID to a 36-byte hexademical string.
---
---@return string uuid 36-byte binary string
function uuid_obj:str() end

---Convert hexademical 36-byte string to an UUID object.
---
---@param uuid_str string UUID in 36-byte hexadecimal string
---@return uuid uuid converted UUID
function uuid.fromstr(uuid_str) end

---Convert binary 16-byte string to an UUID object.
---
---@param uuid_bin string UUID in 16-byte binary string
---@param byte_order? uuid.byte_order Byte order of the resulting UUID
---@return uuid uuid converted UUID
function uuid.frombin(uuid_bin, byte_order) end

---Check if the object is UUID.
---
---*Since 2.6.1*
---
---@param value any
---@return boolean is_uuid true if the specified value is a uuid, and false otherwise
function uuid.is_uuid(value) end

---Check if the UUID is `nil`.
---
---The all-zero UUID value can be expressed as [`uuid.NULL`](lua://uuid.NULL), or as `uuid.fromstr('00000000-0000-0000-0000-000000000000')`.
---
---The comparison with an all-zero value can also be expressed as `uuid_with_type_cdata == uuid.NULL`.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> uuid = require('uuid')
--- ---
--- ...
--- tarantool> uuid(), uuid.bin(), uuid.str()
--- ---
--- - 16ffedc8-cbae-4f93-a05e-349f3ab70baa
--- - !!binary FvG+Vy1MfUC6kIyeM81DYw==
--- - 67c999d2-5dce-4e58-be16-ac1bcb93160f
--- ...
--- tarantool> uu = uuid()
--- ---
--- ...
--- tarantool> #uu:bin(), #uu:str(), type(uu), uu:isnil()
--- ---
--- - 16
--- - 36
--- - cdata
--- - false
--- ...
--- ```
---
---@param value nilany
---@return boolean is_nil true if the specified value is a nil uuid, and false otherwise
function uuid.is_nil(value) end

---Zero UUID.
---
---Equivalent to `uuid.fromstr('00000000-0000-0000-0000-000000000000')`.
---
---@type uuid
uuid.NULL = nil

return uuid
