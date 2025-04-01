---@meta

---@class log
local log = {}

---Log a message with the warn level.
---
---* A message can be a string.
---* A message may contain C-style format specifiers `%d` or `%s`. Example:
---* A message may be a scalar data type or a table. Example:
---
---The actual output will be a line in the log, containing:
---* The current timestamp
---* A module name
---* 'E', 'W', 'I', 'V' or 'D' depending on the called function.
---* `message`.
---
---**Example:**
---
--- ```lua
--- local log = require('log')
--- log.cfg { level = 'verbose' }
--- log.warn('Warning message')
--- log.info('Tarantool version: %s', box.info.version)
--- log.error({ 500, 'Internal error' })
--- log.debug('Debug message')
--- ```
---
---Note that the message will not be logged if the severity level corresponding to the called function is less than [`log.level`](doc://configuration_reference_log_level).
---
---@param s any
---@param ... any
function log.warn(s, ...) end

---Log a message with the info level.
---
---* A message can be a string.
---* A message may contain C-style format specifiers `%d` or `%s`. Example:
---* A message may be a scalar data type or a table. Example:
---
---The actual output will be a line in the log, containing:
---* The current timestamp
---* A module name
---* 'E', 'W', 'I', 'V' or 'D' depending on the called function.
---* `message`.
---
---**Example:**
---
--- ```lua
--- local log = require('log')
--- log.cfg { level = 'verbose' }
--- log.warn('Warning message')
--- log.info('Tarantool version: %s', box.info.version)
--- log.error({ 500, 'Internal error' })
--- log.debug('Debug message')
--- ```
---
---Note that the message will not be logged if the severity level corresponding to the called function is less than [`log.level`](doc://configuration_reference_log_level).
---
---@param s any
---@param ... any
function log.info(s, ...) end

---Log a message with the error level.
---
---* A message can be a string.
---* A message may contain C-style format specifiers `%d` or `%s`. Example:
---* A message may be a scalar data type or a table. Example:
---
---The actual output will be a line in the log, containing:
---* The current timestamp
---* A module name
---* 'E', 'W', 'I', 'V' or 'D' depending on the called function.
---* `message`.
---
---**Example:**
---
--- ```lua
--- local log = require('log')
--- log.cfg { level = 'verbose' }
--- log.warn('Warning message')
--- log.info('Tarantool version: %s', box.info.version)
--- log.error({ 500, 'Internal error' })
--- log.debug('Debug message')
--- ```
---
---Note that the message will not be logged if the severity level corresponding to the called function is less than [`log.level`](doc://configuration_reference_log_level).
---
---@param s any
---@param ... any
function log.error(s, ...) end

---Log a message with the verbose level.
---
---* A message can be a string.
---* A message may contain C-style format specifiers `%d` or `%s`. Example:
---* A message may be a scalar data type or a table. Example:
---
---The actual output will be a line in the log, containing:
---* The current timestamp
---* A module name
---* 'E', 'W', 'I', 'V' or 'D' depending on the called function.
---* `message`.
---
---**Example:**
---
--- ```lua
--- local log = require('log')
--- log.cfg { level = 'verbose' }
--- log.warn('Warning message')
--- log.info('Tarantool version: %s', box.info.version)
--- log.error({ 500, 'Internal error' })
--- log.debug('Debug message')
--- ```
---
---Note that the message will not be logged if the severity level corresponding to the called function is less than [`log.level`](doc://configuration_reference_log_level).
---
---@param s any
---@param ... any
function log.verbose(s, ...) end

---Log a message with the debug level.
---
---* A message can be a string.
---* A message may contain C-style format specifiers `%d` or `%s`. Example:
---* A message may be a scalar data type or a table. Example:
---
---The actual output will be a line in the log, containing:
---* The current timestamp
---* A module name
---* 'E', 'W', 'I', 'V' or 'D' depending on the called function.
---* `message`.
---
---**Example:**
---
--- ```lua
--- local log = require('log')
--- log.cfg { level = 'verbose' }
--- log.warn('Warning message')
--- log.info('Tarantool version: %s', box.info.version)
--- log.error({ 500, 'Internal error' })
--- log.debug('Debug message')
--- ```
---
---Note that the message will not be logged if the severity level corresponding to the called function is less than [`log.level`](doc://configuration_reference_log_level).
---
---@param s any
---@param ... any
function log.debug(s, ...) end

---Set log level.
---
---@param lvl? number
function log.level(lvl) end

---Create a new logger with the specified name.
---
---*Since 2.11.0*
---
---You can configure a specific log level for a new logger using the `log.modules` configuration property.
---
---@param name string
---@return log
function log.new(name) end

return log
