---@meta

---# Builtin `clock` module
---
---The `clock` module returns time values derived from the Posix / C CLOCK_GETTIME_ function or equivalent. Most functions in the module return a number of seconds; functions whose names end in "64" return a 64-bit number of nanoseconds.
local clock = {}

---Get the wall clock time in seconds.
---
---The wall clock time. Derived from C function `clock_gettime(CLOCK_REALTIME)`.
---
---**Example:**
---
--- ```lua
--- -- This will print an approximate number of years since 1970.
--- clock = require('clock')
--- print(clock.time() / (365*24*60*60))
--- ```
---
---@return number
function clock.time() end

---Get the wall clock time in seconds.
---
---The wall clock time. Derived from C function `clock_gettime(CLOCK_REALTIME)`.
---
---**Example:**
---
--- ```lua
--- -- This will print an approximate number of years since 1970.
--- clock = require('clock')
--- print(clock.realtime() / (365*24*60*60))
--- ```
---
---@return number
function clock.realtime() end

---Get the wall clock time in nanoseconds.
---
---The wall clock time. Derived from C function `clock_gettime(CLOCK_REALTIME)`.
---
---**Example:**
---
--- ```lua
--- -- This will print an approximate number of years since 1970.
--- clock = require('clock')
--- print(clock.time() / (365*24*60*60))
--- ```
---
---@return uint64_t
function clock.time64() end

---Get the wall clock time in nanoseconds.
---
---The wall clock time. Derived from C function `clock_gettime(CLOCK_REALTIME)`.
---
---**Example:**
---
--- ```lua
--- -- This will print an approximate number of years since 1970.
--- clock = require('clock')
--- print(clock.realtime() / (365*24*60*60))
--- ```
---
---@return uint64_t
function clock.realtime64()	end

---Get the monotonic time in seconds.
---
---The monotonic time. Derived from C function `clock_gettime(CLOCK_MONOTONIC)`.
---
---Monotonic time is similar to wall clock time but is not affected by changes to or from daylight saving time, or by changes done by a user.
---
---This is the best function to use with benchmarks that need to calculate elapsed time.
---
---**Example:**
---
--- ```lua
--- -- This will print seconds since the start.
--- clock = require('clock')
--- print(clock.monotonic())
--- ```
---
---@see clock.monotonic64
---
---@return number
function clock.monotonic() end

---Get the monotonic time in nanoseconds.
---
---The monotonic time. Derived from C function `clock_gettime(CLOCK_MONOTONIC)`.
---
---Monotonic time is similar to wall clock time but is not affected by changes to or from daylight saving time, or by changes done by a user.
---
---This is the best function to use with benchmarks that need to calculate elapsed time.
---
---**Example:**
---
--- ```lua
--- -- This will print nanoseconds since the start.
--- clock = require('clock')
--- print(clock.monotonic64())
--- ```
---
---@see clock.monotonic
---
---@return uint64_t
function clock.monotonic64() end

---Get the processor time in seconds.
---
---Derived from C function `clock_gettime(CLOCK_PROCESS_CPUTIME_ID)`.
---
---This is the best function to use with benchmarks that need to calculate how much time has been spent within a CPU.
---
---**Example:**
---
--- ```lua
--- -- This will print seconds in the CPU since the start.
--- clock = require('clock')
--- print(clock.proc())
--- ```
---
---@see clock.proc64
---
---@return number
function clock.proc() end

---Get the processor time in nanoseconds.
---
---Derived from C function `clock_gettime(CLOCK_PROCESS_CPUTIME_ID)`.
---
---This is the best function to use with benchmarks that need to calculate how much time has been spent within a CPU.
---
---**Example:**
---
--- ```lua
--- -- This will print nanoseconds in the CPU since the start.
--- clock = require('clock')
--- print(clock.proc64())
--- ```
---
---@see clock.proc
---
---@return uint64_t
function clock.proc64() end

---Get the thread time in seconds.
---
---The thread time. Derived from C function `clock_gettime(CLOCK_THREAD_CPUTIME_ID)`.
---
---This is the best function to use with benchmarks that need to calculate how much time has been spent within a thread within a CPU.
---
---**Example:**
---
--- ```lua
--- -- This will print seconds in the thread since the start.
--- clock = require('clock')
--- print(clock.thread())
--- ```
---
---@see clock.thread64
---
---@return number
function clock.thread() end

---Get the thread time in nanoseconds.
---
---The thread time. Derived from C function `clock_gettime(CLOCK_THREAD_CPUTIME_ID)`.
---
---This is the best function to use with benchmarks that need to calculate how much time has been spent within a thread within a CPU.
---
---**Example:**
---
--- ```lua
--- -- This will print nanoseconds in the thread since the start.
--- clock = require('clock')
--- print(clock.thread64())
--- ```
---
---@see clock.thread
---
---@return uint64_t
function clock.thread64() end

---Measure the time a function takes within a processor.
---
---The time that a function takes within a processor. This function uses `clock.proc()`, therefore it calculates elapsed CPU time. Therefore it is not useful for showing actual elapsed time.
---
---**Example:**
---
--- ```lua
--- -- Benchmark a function which sleeps 10 seconds.
--- -- NB: bench() will not calculate sleep time.
--- -- So the returned value will be {a number less than 10, 88}.
--- clock = require('clock')
--- fiber = require('fiber')
--- function f(param)
---   fiber.sleep(param)
---   return 88
--- end
--- clock.bench(f, 10)
--- ```
---
---@see clock.proc
---
---@generic T...
---@param func fun(...: T...)
---@param ... T...
---@return table
function clock.bench(func, ...) end

return clock
