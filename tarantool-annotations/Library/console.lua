---@meta
--luacheck: ignore
--TODO:

---# Builtin `console` module
---
---The console module allows one Tarantool instance to access another Tarantool instance, and allows one Tarantool instance to start listening on an `admin port`.
local console = {}

---Connect to the instance at URI.
---
---Change the prompt from '`tarantool>`' to ':samp:`{uri}>`', and act henceforth as a client until the user ends the session or types `control-D`.
---
---The console.connect function allows one Tarantool instance, in interactive mode, to access another Tarantool instance. Subsequent requests will appear to be handled locally, but in reality the requests are being sent to the remote instance and the local instance is acting as a client. Once connection is successful, the prompt will change and subsequent requests are sent to, and executed on, the remote instance. Results are displayed on the local instance. To return to local mode, enter `control-D`.
---
---If the Tarantool instance at `uri` requires authentication, the connection might look something like: `console.connect('admin:secretpassword@distanthost.com:3301')`.
---
---There are no restrictions on the types of requests that can be entered, except those which are due to privilege restrictions -- by default the login to the remote instance is done with user name = 'guest'. The remote instance could allow for this by granting at least one privilege: `box.schema.user.grant('guest','execute','universe')`.
---
---**Possible errors:** the connection will fail if the target Tarantool instance was not initiated with `box.cfg{listen=...}`.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> console = require('console')
--- ---
--- ...
--- tarantool> console.connect('198.18.44.44:3301')
--- ---
--- ...
--- 198.18.44.44:3301> -- prompt is telling us that instance is remote
--- ```
---
---@param uri uri_like
function console.connect(uri) end

---Listen for incoming requests.
---
---The primary way of listening for incoming requests is via the connection-information string, or URI, specified in `box.cfg{listen=...}`.
---
---The alternative way of listening is via the URI specified in `console.listen(...)`. This alternative way is called
---"administrative" or simply :ref:`"admin port" <admin-security>`.
---The listening is usually over a local host with a Unix domain socket.
---
---:param string uri: the URI of the local instance
---
---The "admin" address is the URI to listen on. It has no default value, so it
---must be specified if connections will occur via an admin port. The parameter
---is expressed with URI = Universal Resource Identifier format, for example
---"/tmpdir/unix_domain_socket.sock", or a numeric TCP port. Connections are
---often made with telnet. A typical port value is 3313.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> console = require('console')
--- ---
--- ...
--- tarantool> console.listen('unix/:/tmp/X.sock')
--- ... main/103/console/unix/:/tmp/X I> started
--- ---
--- - fd: 6
--- name:
--- host: unix/
--- family: AF_UNIX
--- type: SOCK_STREAM
--- protocol: 0
--- port: /tmp/X.sock
--- ...
--- ```
---
---@param uri uri_like
function console.listen(uri) end

---Start the console on the current interactive terminal.
---
---**Example:**
---
---A special use of `console.start()` is with [`initialization files`](doc://index-init_label).
---
---Normally, if one starts the Tarantool instance with tarantool initialization file there is no console. This can be
---remedied by adding these lines at the end of the initialization file:
---
--- ```lua
--- local console = require('console')
--- console.start()
--- ```
function console.start() end

---Set the auto-completion flag.
---
---If auto-completion is `true`, and the user is using Tarantool as a client or the user is using Tarantool via `console.connect()`, then hitting the TAB key may cause tarantool to complete a word automatically. The default auto-completion value is `true`.
---
---@param auto_completion_flag boolean
function console.ac(auto_completion_flag) end

---Set a custom end-of-request marker for Tarantool console.
--- 
---The default end-of-request marker is a newline (line feed).
---
---Custom markers are not necessary because Tarantool can tell when a multi-line request has not ended (for example, if it sees that a function declaration does not have an end keyword). Nonetheless for special needs, or for entering multi-line requests in older Tarantool versions, you can change the end-of-request marker. As a result, newline alone is not treated as end of request.
function console.delimiter(marker) end

---Get default output format.
---
---Return the current default output format.
---
---@return { fmt: "yaml" | "lua" } format
function console.get_default_output() end

---Set default output format.
---
---@param format { fmt: "yaml" | "lua" }
function console.set_default_output(format) end

---Set or access the end-of-output string if default output is 'lua'.
---
---This is the string that appears at the end of output in a response to any Lua request.
---
---The default value is `;` semicolon. Saying `eos()` will return the current value.
---
---For example, after `require('console').eos('!!')` responses will end with '!!'.
function console.eos(str) end

return console
