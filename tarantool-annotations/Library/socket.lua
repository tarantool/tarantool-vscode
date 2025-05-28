---@meta

---# Builtin `socket` module.
---
---The `socket` module allows exchanging data via BSD sockets with a local or remote host in connection-oriented (TCP) or datagram-oriented (UDP) mode. Semantics of the calls in the `socket` API closely follow semantics of the corresponding POSIX calls.
---
---@class socket_module
---@overload fun(): socket_object
local socket = {}

---@class socket: table
local socket_object = {}

---Returns file descriptor of the socket.
---
--- The `socket` module allows exchanging data via BSD sockets with a local or remote host in connection-oriented (TCP) or datagram-oriented (UDP) mode. Semantics of the calls in the `socket` API closely follow semantics of the corresponding POSIX calls.
---
--- The functions for setting up and connecting are `socket`, `sysconnect`, `tcp_connect`. The functions for sending data are `send`, `sendto`, `write`, `syswrite`. The functions for receiving data are `recv`, `recvfrom`, `read`. The functions for waiting before sending/receiving data are `wait`, `readable`, `writable`. The functions for setting flags are `nonblock`, `setsockopt`. The functions for stopping and disconnecting are `shutdown`, `close`. The functions for error checking are `errno`, `error`.
---
---@return number fd file descriptor
function socket_object:fd() end

---Connect a socket to a remote host.
---
---@async
---@param host string URL or IP address
---@param port number | string? port number string for unix socket
---@param timeout number? number of seconds to wait
---@return socket
---@return nil, string error_message
function socket.tcp_connect(host, port, timeout) end

---The socket.getaddrinfo() function is useful for finding information about a remote site so that the correct arguments for sock:sysconnect() can be passed. This function may use the worker_pool_threads configuration parameter.
---
---@async
---@overload fun(host: string, port: number|string, options?: { type: string, family: string, flags: any, protocol: string })
---@param host string URL or IP address
---@param port number|string port number as a numeric or string
---@param timeout? number maximum number of seconds to wait
---@param options? { type: string, family: string, flags: any, protocol: string }
---@return {host: string, family: string, type: string, protocol: string, port: number}[]?, string error_message
function socket.getaddrinfo(host, port, timeout, options) end


---@class socket.tcp_server_handler
---@field handler fun(client: socket) client handler, executed once after accept() happens (once per connection)
---@field prepare fun(server: socket): number? it may have parameters = the socket object and a table with client information; it should return either a backlog value or nothing;
---@field name string

---The socket.tcp_server() function makes Tarantool act as a server that can accept connections.
---
---@async
---@param host string host name or IP
---@param port number host port, may be 0
---@param handler fun(client: socket) | socket.tcp_server_handler what to execute when a connection occurs
---@param timeout? number host resolving timeout in seconds
---@return socket
---@return nil, string error_message
function socket.tcp_server(host, port, handler, timeout) end

---Bind a socket to the given host/port.
---
---@param host string URL or IP address
---@param port number port number
---@return socket
---@return nil, string error_message
function socket.bind(host, port) end

---Connect an existing socket to a remote host. The argument values are the same as in tcp_connect(). The host must be an IP address.
---
---@param host string|number representation of an IPv4 address or an IPv6 address; or “unix/”; or number, 0 (zero), meaning “all local interfaces”;
---@param port number|string port number; or path to a unix socket.; or If a port number is 0 (zero), the socket will be bound to a random local port.
---@return boolean success
function socket_object:sysconnect(host, port) end

---Send data over a connected socket.
---@param data string what is to be sent
---@return number # number of bytes send
---@return nil # on error
function socket_object:send(data) end

---Send data over a connected socket.
---
---@param data string what is to be sent
---@return number # number of bytes send
---@return nil # on error
function socket_object:write(data) end

---Write as much data as possible to the socket buffer if non-blocking.
---
---Rarely used.
---
---@param data string what is to be sent
---@return number # number of bytes send
---@return nil # on error
function socket_object:syswrite(data) end


---Read size bytes from a connected socket. An internal read-ahead buffer is used to reduce the cost of this call.
---
---For recv and recvfrom: use the optional size parameter to limit the number of bytes to receive. A fixed size such as 512 is often reasonable; a pre-calculated size that depends on context – such as the message format or the state of the network – is often better. For recvfrom, be aware that a size greater than the Maximum Transmission Unit can cause inefficient transport. For Mac OS X, be aware that the size can be tuned by changing sysctl net.inet.udp.maxdgram.
---
---If size is not stated: Tarantool will make an extra call to calculate how many bytes are necessary. This extra call takes time, therefore not stating size may be inefficient.
---
---If size is stated: on a UDP socket, excess bytes are discarded. On a TCP socket, excess bytes are not discarded and can be received by the next call.
---
---@param size integer maximum number of bytes to receive.
---@return string result string of the requested length on success.
---@return string empty_string, integer status, integer errno, string errstr on error
function socket_object:recv(size) end


---Read from a connected socket until some condition is true, and return the bytes that were read
---
---Unlike socket_object:recv (which uses an internal read-ahead buffer), socket_object:read depends on the socket's buffer.
---
---@async
---@param limit integer maximum number of bytes to read, for example 50 means “stop after 50 bytes”
---@param timeout? number maximum number of seconds to wait, for example 50 means “stop after 50 seconds”
---@return string data in case of success
---@return string empty_string if there is nothing more to read
---@return nil # if error
function socket_object:read(limit, timeout) end

---Read from a connected socket until some condition is true, and return the bytes that were read
---
---Unlike socket_object:recv (which uses an internal read-ahead buffer), socket_object:read depends on the socket's buffer.
---
---@async
---@param delimiter string separator for example '?' means “stop after a question mark”
---@param timeout? number maximum number of seconds to wait, for example 50 means “stop after 50 seconds”.
---@return string data in case of success
---@return string empty_string if there is nothing more to read
---@return nil # if error
function socket_object:read(delimiter, timeout) end

---Read from a connected socket until some condition is true, and return the bytes that were read.
---
---Unlike socket_object:recv (which uses an internal read-ahead buffer), socket_object:read depends on the socket's buffer.
---
---@async
---@param options { chunk: integer?, delimiter: string? } chunk=limit and/or delimiter=delimiter, for example {chunk=5,delimiter='x'}
---@param timeout? number maximum number of seconds to wait, for example 50 means “stop after 50 seconds”.
---@return string data in case of success
---@return string empty_string if there is nothing more to read
---@return nil # if error
function socket_object:read(options, timeout) end

---Return data from the socket buffer if non-blocking. In case the socket is blocking, sysread() can block the calling process. Rarely used.
---
---@param size integer
---@return string data in case of success
---@return string empty_string if there is nothing more to read
---@return nil # if error
function socket_object:sysread(size) end

---Bind a socket to the given host/port.
---
---A UDP socket after binding can be used to receive data (see socket_object.recvfrom).
---
---A TCP socket can be used to accept new connections, after it has been put in listen mode.
---
---@param host string URL or IP address
---@param port integer? port number
---@return boolean success true for success, false for error. If return is false, use socket_object:errno() or socket_object:error() to see details.
function socket_object:bind(host, port) end

---Start listening for incoming connections.
---
---@param backlog number on Linux the listen backlog backlog may be from /proc/sys/net/core/somaxconn, on BSD the backlog may be SOMAXCONN
---@return boolean success true for success, false for error.
function socket_object:listen(backlog) end

---Accept a new client connection and create a new connected socket.
---
---It is good practice to set the socket's blocking mode explicitly after accepting.
---
---@return socket client new socket if success.
---@return nil # if error
function socket_object:accept() end

---Send a message on a UDP socket to a specified host.
---
---@param host string URL or IP address
---@param port number port number
---@param data string what is to be sent
---@return number bytes the number of bytes sent.
---@return nil, number? status, number? errno, string? errstr  on error, returns nil and may return status, errno, errstr.
function socket_object:sendto(host, port, data) end

---Receive a message on a UDP socket.
---
---@param size? number maximum number of bytes to receive.
---@return string message, { host: string, family: string, port: number } source on success
---@return nil, number status, number errno, string errstr on error
function socket_object:recvfrom(size) end

---Shutdown a reading end, a writing end, or both ends of a socket.
---
---@param how number socket.SHUT_RD, socket.SHUT_WR, or socket.SHUT_RDWR.
---@return boolean success
function socket_object:shutdown(how) end

---Close (destroy) a socket.
---
---A closed socket should not be used any more.
---
---A socket is closed automatically when the Lua garbage collector removes its user data.
---
---@return boolean success true on success, false on error. For example, if sock is already closed, sock:close() returns false.
function socket_object:close() end

---Retrieve information about the last error that occurred on a socket, if any.
---
---Errors do not cause throwing of exceptions so these functions are usually necessary.
---
---@return number errno if no error 0 is returned
function socket_object:errno() end

---Retrieve information about the last error that occurred on a socket, if any.
---
---Errors do not cause throwing of exceptions so these functions are usually necessary.
---
---@return string errstr
function socket_object:error() end

---Set socket flags.
---
---@param level any
---@param name any
---@param value any
function socket_object:setsockopt(level, name, value) end

---Get socket flags.
---
---@param level any
---@param name any
function socket_object:getsockopt(level, name) end

---Set or clear the SO_LINGER flag.
---
---@param active boolean
function socket_object:linger(active) end

---Returns the current O_NONBLOCK value.
---
---@return boolean nonblock_flag
function socket_object:nonblock() end

---Sets O_NONBLOCK flag.
---
---@param flag boolean
---@return boolean new_flag_value
function socket_object:nonblock(flag) end

---Wait until something is readable, or until a timeout value expires.
---
---@async
---@param timeout? number timeout in seconds
---@return boolean is_readable true if the socket is now readable, false if timeout expired;
function socket_object:readable(timeout) end

---Wait until something is writable, or until a timeout value expires.
---
---@async
---@param timeout? number timeout in seconds
---@return boolean is_writable true if the socket is now writable, false if timeout expired;
function socket_object:writable(timeout) end

---Wait until something is either readable or writable, or until a timeout value expires.
---
---@async
---@param timeout? number timeout
---@return "R"|"W"|"RW"|"" # 'R' if the socket is now readable, 'W' if the socket is now writable, 'RW' if the socket is now both readable and writable, '' (empty string) if timeout expired;
function socket_object:wait(timeout) end


---Get information about the near side of the connection.
---
---The equivalent POSIX function is `getsockname()`.
---
---@return { host: string, family: string, type: string, protocol: string, port: number }
function socket_object:name() end

---Get information about the far side of a connection.
---
---The equivalent POSIX function is `getpeername()`.
---
---@return { host: string, family: string, type: string, protocol: string, port: number }
function socket_object:peer() end

---Wait until read-or-write activity occurs for a file descriptor.
---
---If the fd parameter is nil, then there will be a sleep until the timeout.
---
---If the timeout parameter is nil or unspecified, then timeout is infinite.
---
---@async
---@param fd number file descriptor
---@param read_or_write_flags "R" | "W" | "RW" | 1 | 2 | 3 # 'R' or 1 = read, 'W' or 2 = write, 'RW' or 3 = read|write.
---@param timeout? number number of seconds to wait
function socket.iowait(fd, read_or_write_flags, timeout) end

return socket
