---@meta

---# Builtin `fiber` module
---
---With the fiber module, you can:
---
---* Create, run, and manage fibers.
---* Send and receive messages between different processes (i.e. different connections, sessions, or fibers) via channels.
---* Use a synchronization mechanism for fibers, similar to "condition variables" and similar to operating-system functions, such as `pthread_cond_wait()` plus `pthread_cond_signal()`.
local fiber = {}

---Create and start a fiber.
---
---The fiber is created and begins to run immediately.
---
---**Example:**
---
---The script below shows how to create a fiber using `fiber.create`.
---
--- ```lua
--- -- app.lua --
--- fiber = require('fiber')
--- 
--- function greet(name)
--- print('Hello, '..name)
--- end
--- 
--- greet_fiber = fiber.create(greet, 'John')
--- print('Fiber already started')
--- ```
---
---@async
---@generic T
---@param func fun(...: T...) the function to be associated with the fiber
---@param ... T... what will be passed to function
---@return fiber
function fiber.create(func, ...) end

---Create a fiber but do not start it.
---
---The created fiber starts after the fiber creator (that is, the job that is calling `fiber.new()`) yields. The initial fiber state is ready.
---
---**Note:** `fiber.status()` returns the suspended state for ready fibers because the ready state is not observable using the fiber module API.
---
---You can join fibers created using `fiber.new()` by calling the `fiber_object:join()` function and get the result returned by the fiber's function.
---
---To join the fiber, you need to make it joinable using `fiber_object:set_joinable()`.
---
---@generic T
---@param func fun(...: T...) the function to be associated with the fiber
---@param ... T... what will be passed to function
---@return fiber
function fiber.new(func, ...) end

---Get the currently scheduled fiber.
---
---@return fiber
function fiber.self() end

---Get a fiber object by ID.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.find(101)
--- ---
--- - status: running
--- name: interactive
--- id: 101
--- ...
--- ```
---
---@param id integer numeric identifier of the fiber.
---@return fiber
function fiber.find(id) end

---Yield control to the scheduler and sleep for the specified number of seconds.
---
---Only the current fiber can be made to sleep.
---
---**Example:**
---
---The `increment` function below contains an infinite loop that adds 1 to the `counter` global variable. Then, the current fiber goes to sleep for `period` seconds. `sleep` causes an implicit [`fiber.yield()`](lua://fiber.yield).
---
--- ```lua
--- -- app.lua --
--- fiber = require('fiber')
--- 
--- counter = 0
--- function increment(period)
---     while true do
---         counter = counter + 1
---         fiber.sleep(period)
---     end
--- end
--- 
--- increment_fiber = fiber.create(increment, 2)
--- require('console').start()
--- ```
---
---@async
---@param timeout number number of seconds to sleep.
function fiber.sleep(timeout) end

---Yield control to the scheduler.
---
---Equivalent to `fiber.sleep(0)`.
---
---**Example:**
---
---In the example below, two fibers are associated with the same function. Each fiber yields control after printing a greeting.
---
--- ```lua
--- -- app.lua --
--- fiber = require('fiber')
--- 
--- function greet()
---     while true do
---         print('Enter a name:')
---         name = io.read()
---         print('Hello, '..name..'. I am fiber '..fiber.id())
---         fiber.yield()
---     end
--- end
--- 
--- for i = 1, 2 do
---     fiber_object = fiber.create(greet)
---     fiber_object:cancel()
--- end
--- ```
---
---@async
function fiber.yield() end

---Return the status of the current fiber.
---
---Or, if optional fiber_object is passed, return the status of the specified fiber.
---
--- ```tarantoolsession
--- tarantool> fiber.status()
--- ---
--- - running
--- ...
--- ```
---
---@param fiber_object? fiber
---@return "running" | "dead" | "suspected"
function fiber.status(fiber_object) end

---@class fiber.info
---@field csw number number of context switches.
---@field memory { total: number, used: number } `total` is memory occupied by the fiber as a C structure, its stack, etc. `actual` is memory used by the fiber.
---@field time number duplicates the “time" entry from fiber.top().cpu for each fiber. (Only shown if fiber.top is enabled.)
---@field name string name of the fiber
---@field fid number id of the fiber
---@field backtrace { C: string, L: string }[] fiber's stack trace

---Return information about all fibers.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.info({ bt = true })
--- ---
--- - 101:
--- csw: 1
--- backtrace:
--- - C: '#0  0x5dd130 in lbox_fiber_id+96'
--- - C: '#1  0x5dd13d in lbox_fiber_stall+13'
--- - L: stall in =[C] at line -1
--- - L: (unnamed) in @builtin/fiber.lua at line 59
--- - C: '#2  0x66371b in lj_BC_FUNCC+52'
--- - C: '#3  0x628f28 in lua_pcall+120'
--- - C: '#4  0x5e22a8 in luaT_call+24'
--- - C: '#5  0x5dd1a9 in lua_fiber_run_f+89'
--- - C: '#6  0x45b011 in fiber_cxx_invoke(int (*)(__va_list_tag*), __va_list_tag*)+17'
--- - C: '#7  0x5ff3c0 in fiber_loop+48'
--- - C: '#8  0x81ecf4 in coro_init+68'
--- memory:
--- total: 516472
--- used: 0
--- time: 0
--- name: lua
--- fid: 101
--- 102:
--- csw: 0
--- backtrace:
--- - C: '#0  (nil) in +63'
--- - C: '#1  (nil) in +63'
--- memory:
--- total: 516472
--- used: 0
--- time: 0
--- name: on_shutdown
--- fid: 102
--- 
--- ...
--- ```
---
---@param opts? { backtrace?: boolean , bt?: boolean }
---@return table<integer, fiber.info>
function fiber.info(opts) end

---@return integer fiber_id returns current fiber id
function fiber.id() end

---@class fiber.top
---@field instant number (in percent) a number which indicates the share of time the fiber was executing during the previous event loop iteration
---@field average number (in percent) a number which is calculated as an exponential moving average of instant values over all the previous event loop iterations
---@field time number (in seconds) a number which estimates how much CPU time each fiber spent processing during its lifetime

---Show all alive fibers and their CPU consumption.
---
---**Note:** *Since 2.11.0* `cpu_misses` is deprecated and always returns `0`.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.top()
--- ---
--- - cpu:
--- 107/lua:
--- instant: 30.967324490456
--- time: 0.351821993
--- average: 25.582738345233
--- 104/lua:
--- instant: 9.6473633128437
--- time: 0.110869897
--- average: 7.9693406131877
--- 101/on_shutdown:
--- instant: 0
--- time: 0
--- average: 0
--- 103/lua:
--- instant: 9.8026528631511
--- time: 0.112641118
--- average: 18.138387232255
--- 106/lua:
--- instant: 20.071174377224
--- time: 0.226901357
--- average: 17.077908441831
--- 102/interactive:
--- instant: 0
--- time: 9.6858e-05
--- average: 0
--- 105/lua:
--- instant: 9.2461986412164
--- time: 0.10657528
--- average: 7.7068458630827
--- 1/sched:
--- instant: 20.265286315108
--- time: 0.237095335
--- average: 23.141537169257
--- cpu_misses: 0
--- ...
--- ```
---
---@return { cpu: table<string,fiber.top>, cpu_misses: number }
function fiber.top() end

---Cancel a fiber.
---
---Locate a fiber by its numeric ID and cancel it. In other words, [`fiber.kill()`](lua://fiber.kill) combines [`fiber.find()`](fiber.find) and [`fiber_object:cancel()`](lua://fiber_object.cancel).
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.kill(fiber.id()) -- kill self, may make program end
--- ---
--- - error: fiber is cancelled
--- ...
--- ```
---
---@param fiber_object fiber
function fiber.kill(fiber_object) end

---Check if the current fiber has been cancelled and throw an exception if this is the case.
---
---**Note:**
---
---Even if you catch the exception, the fiber will remain cancelled. Most types of calls will check `fiber.testcancel()`. However, some functions (`id`, `status`, `join` etc.) will return no error.
---
---We recommend application developers to implement occasional checks with [`fiber.testcancel()`](lua://fiber.testcancel) and to end fiber's execution as soon as possible in case it has been cancelled.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.testcancel()
--- ---
--- - error: fiber is cancelled
--- ...
--- ```
-
function fiber.testcancel() end

---Get the current system time (in seconds since the epoch) as a Lua number.
---
---The time is taken from the event loop clock, which makes this call very cheap, but still useful for constructing artificial tuple keys.
---
---**Example:**
---
--- ```
--- tarantool> fiber.time(), fiber.time()
--- - 1448466279.2415
--- - 1448466279.2415
--- ```
---
---@see fiber.time64
---
---@return number
function fiber.time() end

---Get the current system time (in microseconds since the epoch) as a 64-bit integer.
---
---The time is taken from the event loop clock.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.time(), fiber.time64()
--- ---
--- - 1448466351.2708
--- - 1448466351270762
--- ...
--- ```
---
---@see fiber.time
---
---@return int64_t
function fiber.time64() end

---Get the monotonic time in seconds.
---
---It is better to use `fiber.clock()` for calculating timeouts instead of `fiber.time()` because `fiber.time()` reports real time so it is affected by system time changes.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> start = fiber.clock()
--- ---
--- ...
--- tarantool> print(start)
--- 248700.58805
--- ---
--- ...
--- tarantool> print(fiber.time(), fiber.time()-start)
--- 1600785979.8291 1600537279.241
--- ---
--- ...
--- ```
---
---@see fiber.clock64
---
---@return number
function fiber.clock() end

---Get the monotonic time in seconds.
---
---Same as `fiber.clock()` but in microseconds.
---
---@see fiber.clock
---
---@return ffi.cdata*
function fiber.clock64() end

---Enable `fiber.top`.
---
---**Note:** Enabling `fiber.top()` slows down fiber switching by about 15%, so it is disabled by default.
---
---@see fiber.top
function fiber.top_enable() end

---Disable `fiber.top`.
---
---**Note:** Enabling `fiber.top()` slows down fiber switching by about 15%, so it is disabled by default.
---
---@see fiber.top
function fiber.top_disable() end

---Check whether a slice for the current fiber is over.
---
---A fiber slice limits the time period of executing a fiber without yielding control.
---
---**Example:**
---
---The example below shows how to use `set_max_slice` to limit the slice for all fibers. `fiber.check_slice()` is called inside a long-running operation to determine whether a slice for the current fiber is over.
---
--- ```lua
--- -- app.lua --
--- fiber = require('fiber')
--- clock = require('clock')
---
--- fiber.set_max_slice({warn = 1.5, err = 3})
--- time = clock.monotonic()
--- function long_operation()
---     while clock.monotonic() - time < 5 do
---         fiber.check_slice()
---         -- Long-running operation ⌛⌛⌛ --
---     end
--- end
--- 
--- long_operation_fiber = fiber.create(long_operation)
--- ```
---
---The output should look as follows:
---
--- ```console
--- $ tarantool app.lua
--- fiber has not yielded for more than 1.500 seconds
--- FiberSliceIsExceeded: fiber slice is exceeded
--- ```
---
function fiber.check_slice() end

---@class fiber.slice
---@field warn number
---@field err number

---Set a slice for the current fiber execution.
---
---A fiber slice limits the time period of executing a fiber without yielding control.
---@param slice fiber.slice | number a time period (in seconds) that specifies the error slice
function fiber.set_slice(slice) end

---Set the default maximum slice for all fibers.
---
---A fiber slice limits the time period of executing a fiber without yielding control.
---
---@param slice fiber.slice | number a time period (in seconds) that specifies the error slice
function fiber.set_max_slice(slice) end

---Extend a slice for the current fiber execution.
---
---For example, if the default error slice is set using `fiber.set_max_slice()` to 3 seconds, `extend_slice(1)` extends the error slice to 4 seconds.
---
---@param slice fiber.slice | number a time period (in seconds) that specifies the error slice
function fiber.extend_slice(slice) end

---@class fiber: userdata
local fiber_object = {}

---Get a fiber's ID
---
---@return number # fiber id
function fiber_object:id() end

---Get or change a fiber's name
---
---Change the fiber name. By default a Tarantool server's interactive-mode fiber is named 'interactive' and new fibers created due to [`fiber.create`](lua://fiber.create) are named 'lua'.
---
---Giving fibers distinct names makes it easier to distinguish them when using [`fiber.info`](lua://fiber.info) and [`fiber.top()`](lua://fiber.top).
---
---Max length is 255.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.self():name('non-interactive')
--- ---
--- ...
--- ```
---
---@param name? string
---@param options? {truncate: boolean}
---@return string name
function fiber_object:name(name, options) end

---Get a fiber's status.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> fiber.self():status()
--- ---
--- - running
--- ...
--- ```
---
---@return "dead" | "running" | "suspended"
function fiber_object:status() end

---Send a cancellation request to the fiber.
---
---Running and suspended fibers can be cancelled. After a fiber has been cancelled, attempts to operate on it cause errors, for example, [`fiber_object:name()`](fiber_object.name) causes `error: the fiber is dead`. But a dead fiber can still report its ID and status.
---
---Cancellation is asynchronous.
---
---Use [`fiber_object:join()`](fiber_object.join) to wait for the cancellation to complete.
---
---After `fiber_object:cancel()` is called, the fiber may or may not check whether it was cancelled. If the fiber does not check it, it cannot ever be cancelled.
---
---**Possible errors:** cancel is not permitted for the specified fiber object.
---
function fiber_object:cancel() end

---Local storage within the fiber.
fiber_object.storage = {}

---Make a fiber joinable.
---
---A joinable fiber can be waited for using [`fiber_object:join()`](lua://fiber_object.join).
---
---The best practice is to call `fiber_object:set_joinable()` before the fiber function begins to execute because otherwise the fiber could become `dead` before `fiber_object:set_joinable()` takes effect.
---
---The usual sequence could be:
---1. Call `fiber.new()` instead of `fiber.create()` to create a new fiber_object. Do not yield at this point, because that will cause the fiber function to begin.
---2. Call `fiber_object:set_joinable(true)` to make the new `fiber_object` joinable. Now it is safe to yield.
---3. Call `fiber_object:join()`.
---
---Usually `fiber_object:join()` should be called, otherwise the fiber's status may become 'suspended' when the fiber function ends, instead of 'dead'.
---
---@param true_or_false boolean
function fiber_object:set_joinable(true_or_false) end

---"Join" a joinable fiber.
---
---That is, let the fiber's function run and wait until the fiber's status is ‘dead' (normally a status becomes ‘dead' when the function execution finishes).
---
---Joining will cause a yield, therefore, if the fiber is currently in a suspended state, execution of its fiber function will resume.
---
---This kind of waiting is more convenient than going into a loop and periodically checking the status.
---
---However, it works only if the fiber was created with `fiber.new()` and was made joinable with `fiber_object:set_joinable()`.
---
---@async
---@return boolean success, any ...
function fiber_object:join() end

---@class fiber.channel
local channel_object = {}

---Create a communication channel.
---
---@param capacity? number the maximum number of slots (spaces for channel:put messages) that can be in use at once. The default is 0.
---@return fiber.channel
function fiber.channel(capacity) end

---Send a message using a channel.
---
---If the channel is full, `channel:put()` waits until there is a free slot in the channel.
---
---**Note:**
---
---The default [`channel capacity`](lua://fiber.channel) is `0`.
---
---With this default value, `channel:put()` *waits infinitely* until `channel:get()` is called.
---
---@async
---@param message any
---@param timeout? number
---@return boolean success If timeout is specified, and there is no free slot in the channel for the duration of the timeout, then the return value is false. If the channel is closed, then the return value is false. Otherwise, the return value is true, indicating success.
function channel_object:put(message, timeout) end

---Close the channel.
---
---All waiters in the channel will stop waiting.
---
---All following `channel:get()` operations will return `nil`, and all following `channel:put()` operations will return `false`.
function channel_object:close() end

---Fetch and remove a message from a channel.
---
---If the channel is empty, `channel:get()` waits for a message.
---
---@async
---@param timeout? number maximum number of seconds to wait for a message. Default: infinity.
---@return any message
function channel_object:get(timeout) end

---Check whether the channel is empty (has no messages).
---
---@return boolean # is_empty
function channel_object:is_empty() end

---Find out how many messages are in the channel.
---
---@return integer
function channel_object:count() end

---Returns size of channel.
---
---@return integer
function channel_object:size() end

---Check if a channel is full.
---
---@return boolean # is_full
function channel_object:is_full() end

---Check whether readers are waiting for a message because they have issued `channel:get()` and the channel is empty.
---
---@return boolean
function channel_object:has_readers() end

---Check whether writers are waiting because they have issued `channel:put()` and the channel is full.
---
---@return boolean
function channel_object:has_writers() end

---Check if a channel is closed.
---
---@return boolean
function channel_object:is_closed() end

---@class fiber.cond: userdata
local cond_object = {}

---Create a new conditional variable.
---
---@return fiber.cond
function fiber.cond() end

---Make the current fiber go to sleep.
---
---Waiting until another fiber invokes the `signal()` or `broadcast()` method on the cond object.
---
---The sleep causes an implicit `fiber.yield()`.
---
---@async
---@param timeout? number number of seconds to wait, default = forever.
---@return boolean was_signalled If timeout is provided, and a signal doesn't happen for the duration of the timeout, wait() returns false. If a signal or broadcast happens, wait() returns true.
function cond_object:wait(timeout) end

---Wake up a single fiber that has executed `wait()` for the same variable.
---
---Does not yield.
function cond_object:signal() end

---Wake up all fibers that have executed `wait()` for the same variable.
---
---Does not yield.
function cond_object:broadcast() end

return fiber
