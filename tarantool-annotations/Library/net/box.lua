---@meta

---# Builtin `net.box` module.
---
---The `net.box` module contains connectors to remote database systems. One variant is for connecting to MySQL or MariaDB or PostgreSQL (see [SQL DBMS modules](doc://dbms_modules) reference).
---
---The other variant, which is discussed in this section, is for connecting to Tarantool server instances via a network.
local net_box = {}

---@class net.box.conn
---@field public host string
---@field public port string
---@field public state 'active' | 'fetch_schema' | 'error' | 'error_reconnect' | 'closed' | 'initial' | 'graceful_shutdown'
---@field public error string
---@field public peer_uuid? string
---@field public _fiber? Fiber
local conn = {}

---@class net.box.request.options
---@field public is_async? boolean
---@field public timeout? number

---@class net.box.call.options
---@field timeout number? Timeout of Call
---@field is_async boolean? makes request asynchronous
---@field return_raw boolean? returns raw msgpack (since version 2.10.0)
---@field on_push fun(ctx: any?, msg: any)? callback for each inbound message
---@field on_push_ctx any? ctx for on_push callback

---Execute a remote call.
---
---`conn:call('func', {'1', '2', '3'})` is the remote-call equivalent of `func('1', '2', '3')`. That is, `conn:call` is a remote stored-procedure call. The return from `conn:call` is whatever the function returns.
---
---Limitation: the called function cannot return a function, for example if `func2` is defined as `function func2 () return func end` then `conn:call(func2)` will return "error: unsupported Lua type 'function'".
---
---**Examples:**
---
--- ```lua
--- tarantool> -- create 2 functions with conn:eval()
--- tarantool> conn:eval('function f1() return 5+5 end;')
--- tarantool> conn:eval('function f2(x,y) return x,y end;')
--- tarantool> -- call first function with no parameters and no options
--- tarantool> conn:call('f1')
--- ---
--- - 10
--- ...
--- tarantool> -- call second function with two parameters and one option
--- tarantool> conn:call('f2',{1,'B'},{timeout=99})
--- ---
--- - 1
--- - B
--- ...
--- ```
---
---@async
---@param func string
---@param args? any[]
---@param opts? net.box.call.options
---@return table
function conn:call(func, args, opts) end

---Execute Lua code remotely.
---
---`conn:eval({Lua-string})` evaluates and executes the expression in Lua-string, which may be any statement or series of statements.
---An [execute privilege](doc://authentication-owners_privileges) is required; if the user does not have it, an administrator may grant it with `box.schema.user.grant({username}, 'execute', 'universe')`.
---
---To ensure hat the return from `conn:eval` is whatever the Lua expression returns, begin the Lua-string with the word "return".
---
---**Examples:**
---
--- ```lua
--- tarantool> --Lua-string
--- tarantool> conn:eval('function f5() return 5+5 end; return f5();')
--- ---
--- - 10
--- ...
--- tarantool> --Lua-string, {arguments}
--- tarantool> conn:eval('return ...', {1,2,{3,'x'}})
--- ---
--- - 1
--- - 2
--- - [3, 'x']
--- ...
--- tarantool> --Lua-string, {arguments}, {options}
--- tarantool> conn:eval('return {nil,5}', {}, {timeout=0.1})
--- ---
--- - [null, 5]
--- ...
--- ```
---
---@async
---@param expression string
---@param args any[]?
---@param opts net.box.call.options?
---@return table
function conn:eval(expression, args, opts) end

---Execute a PING command.
---
---@async
---@param opts? { timeout: number }
---@return boolean
function conn:ping(opts) end

---Define a trigger for execution when a new connection is established, and authentication and schema fetch are completed due to an event such as `net_box.connect`.
---
---If a trigger function issues `net_box` requests, they must be [asynchronous](net.box.is_async) (`{is_async = true}`). An attempt to wait for request completion with `future:pairs()` or `future:wait_result()` in the trigger function will result in an error.
---
---If the trigger execution fails and an exception happens, the connection's state changes to 'error'. In this case, the connection is terminated, regardless of the `reconnect_after` option's value. Can be called as many times as reconnection happens, if `reconnect_after` is greater than zero.
---
---@param new_callback fun(conn: net.box.conn)
---@param old_callback? fun(conn: net.box.conn)
function conn:on_connect(new_callback, old_callback) end

---Define a trigger for execution after a connection is closed.
---
---If the trigger function causes an error, the error is logged but otherwise is ignored.
---
---Execution stops after a connection is explicitly closed, or once the Lua garbage collector removes it.
---
---@param new_callback fun(conn: net.box.conn)
---@param old_callback? fun(conn: net.box.conn)
function conn:on_disconnect(new_callback, old_callback) end

---Wait for connection to be active or closed.
---
---**Example:**
---
--- ```lua
--- net_box.self:wait_connected()
--- ```
---
---@async
---@param wait_timeout number
---@return boolean is_connected true when connected, false on failure.
function conn:wait_connected(wait_timeout) end

---Close a connection.
---
---Connection objects are destroyed by the Lua garbage collector, just like any other objects in Lua, so an explicit destruction is not mandatory. However, since `close()` is a system call, it is good programming practice to close a connection explicitly when it is no longer needed, to avoid lengthy stalls of the garbage collector.
---
---**Example:**
---
--- ```lua
--- conn:close()
--- ```
---
function conn:close() end

---Show whether connection is active or closed.
---
---@return boolean
function conn:is_connected() end

---@class net.box.connect.options
---@field public wait_connected? boolean|number
---@field public reconnect_after? number
---@field public user? string
---@field public password? string
---@field public connect_timeout? number

---Creates a new connection to Tarantool.
---
---The connection is established on demand, at the time of the first request.
---
---It can be re-established automatically after a disconnect (see `reconnect_after` option below).
---
---The returned `conn` object supports methods for making remote requests, such as `select`, `update` or `delete`.
---
---If `reconnect_after` is greater than zero, then `wait_connected` ignores transient failures.
---The wait completes once the connection is established or is closed explicitly.
---
---* `reconnect_after`: a number of seconds to wait before reconnecting.
---
---The default value, as with the other `connect` options, is `nil`. If `reconnect_after` is greater than zero, then a `net.box` instance will attempt to reconnect if a connection is lost or a connection attempt fails. This makes transient network failures transparent to the application.
---
---Reconnection happens automatically in the background, so requests that initially fail due to connection drops fail, are transparently retried. The number of retries is unlimited, connection retries are made after any specified interval (for example, `reconnect_after=5` means that reconnect attempts are made every 5 seconds).
---When a connection is explicitly closed or when the Lua garbage collector removes it, then reconnect attempts stop.
---
---* `connect_timeout`: a number of seconds to wait before returning "error: Connection timed out".
---* `fetch_schema`: a boolean option that controls fetching schema changes from the server. Default: `true`.
---If you don't operate with remote spaces, for example, run only `call` or `eval`, set `fetch_schema` to false` to avoid fetching schema changes which is not needed in this case.
---
---**Important:** In connections with `fetch_schema == false`, remote spaces are unavailable and the [`on_schema_reload`](lua://<net.box.on_schema_reload) triggers don't work.
---
---* `required_protocol_version`: a minimum version of the [IPROTO protocol](doc://box_protocol-id) supported by the server. If the version of the [IPROTO protocol](doc://box_protocol-id) supported by the server is lower than specified, the connection will fail with an error message.
---
---With `required_protocol_version = 1`, all connections fail where the [IPROTO protocol](doc://box_protocol-id) version is lower than `1`.
---
---* `required_protocol_features`: specified [IPROTO protocol features](doc://box_protocol-id) supported by the server.
---You can specify one or more `net.box` features from the table below. If the server does not support the specified features, the connection will fail with an error message.
---
---With `required_protocol_features = {'transactions'}`, all connections fail where the server has `transactions: false`.
---
---*  net.box feature
---   Use
---   IPROTO feature ID
---   IPROTO versions supporting the feature
---* `streams`
---   Requires streams support on the server
---   IPROTO_FEATURE_STREAMS
---   1 and newer
---* `transactions`
---   Requires transactions support on the server
---   IPROTO_FEATURE_TRANSACTIONS
---   1 and newer
---* `error_extension`
---   Requires support for [`MP_ERROR`](lua://msgpack.ext.error) MsgPack extension on the server
---   IPROTO_FEATURE_ERROR_EXTENSION
---   2 and newer
---* `watchers`
---   Requires remote [`watchers`](lua://net.boxwatch) support on the server
---   IPROTO_FEATURE_WATCHERS
---   3 and newer
---
---To learn more about IPROTO features, see [`IPROTO_ID`](box.protocol.id) and the [`IPROTO_FEATURES]`(doc://internals-iproto-keys-features) key.
---
---**Examples:**
---
--- ```lua
--- net_box = require('net.box')
--- 
--- conn = net_box.connect('localhost:3301')
--- conn = net_box.connect('127.0.0.1:3302', {wait_connected = false})
--- conn = net_box.connect('127.0.0.1:3304', {required_protocol_version = 4, required_protocol_features = {'transactions', 'streams'}, })
--- ```
---
---@async
---@param endpoint uri_like
---@param options? net.box.connect.options
---@return net.box.conn
function net_box.connect(endpoint, options) end

---Creates connection to Tarantool.
---
---`new()` is a synonym for `connect()`. It is retained for backward compatibility.
---
---For more information, see the description of [`net_box.connect()`](net.box.connect).
---
---@see net.box.connect
---
---@async
---@param endpoint string
---@param options net.box.connect.options
---@return net.box.conn
function net_box.new(endpoint, options) end

return net_box
