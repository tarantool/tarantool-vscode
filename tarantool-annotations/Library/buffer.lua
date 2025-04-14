---@meta

---# Builtin `buffer` module
---
---The buffer module returns a dynamically resizable buffer which is solely for optional use by methods of the net.box module or the msgpack module.
local buffer = {}

---@class buffer
---@field buf ffi.cdata* A pointer to the beginning of the buffer
---@field rpos ffi.cdata* A pointer to the beginning of the range; available for reading data ("read position")
---@field wpos ffi.cdata* A pointer to the end of the range; available for reading data, and to the beginning of the range for writing new data ("write position")
---@field epos ffi.cdata* A pointer to the end of the range; available for writing new data ("end position")
local buffer_object = {}

---Create a new buffer
---
---@param size? integer
---@return buffer
function buffer.ibuf(size) end

---Allocate size bytes for buffer_object.
---
---@param size integer memory in bytes to allocate
---@return ffi.cdata* wpos
function buffer_object:alloc(size) end

---Return the capacity of the buffer_object.
---
---@return integer # wpos - buf
function buffer_object:capacity() end

---Check if size bytes are available for reading in buffer_object.
---
---@param size integer memory in bytes to check
---@return ffi.cdata* rpos
function buffer_object:checksize(size) end.

---Return the size of the range occupied by data.
---
---@return integer # rpos - buf
function buffer_object:pos() end

---Read from buffer.
---
---@param size integer Read size bytes from buffer.
function buffer_object:read(size) end

---Clear the memory slots allocated by buffer_object.
---
function buffer_object:recycle() end

---Clear the memory slots used by buffer_object.
---
---This method allows to keep the buffer but remove data from it.
---It is useful when you want to use the buffer further.
function buffer_object:reset() end

---Reserve memory for buffer_object.
---
---Check if there is enough memory to write `size` bytes after `wpos`.
---If not, `epos` shifts until `size` bytes will be available.
---
---@param size integer
function buffer_object:reserve(size) end

---Return a range, available for reading data.
---
---@return integer # wpos - rpos
function buffer_object:size() end

---Return a range for writing data.
---
---@return integer # epos - wpos
function buffer_object:unused() end

return buffer
