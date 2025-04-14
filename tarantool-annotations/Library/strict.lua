---@meta

---# Builtin `strict` module
---
---The strict module has functions for turning "strict mode" on or off. When strict mode is on, an attempt to use an undeclared global variable will cause an error. A global variable is considered “undeclared” if it has never had a value assigned to it. Often this is an indication of a programming error.
---
---By default strict mode is off, unless tarantool was built with the -DCMAKE_BUILD_TYPE=Debug option
local strict = {}

---Enables strict mode.
function strict.on() end

---Disables strict mode.
function strict.off() end

return strict
