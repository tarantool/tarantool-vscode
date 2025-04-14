---@meta

---# Builtin `http.client` submodule
---
---The `http` module, specifically the `http.client` submodule, provides the functionality of an HTTP client with support for HTTPS and keepalive.
---
---The HTTP client uses the [`libcurl`](https://curl.haxx.se/libcurl/) library under the hood and takes into account the [environment variables](https://curl.haxx.se/libcurl/c/libcurl-env.html) libcurl understands.
local http = {}

local http_client = {}

---@class http.client.options
---@field max_connections? integer is the maximum number of entries in the cache. It affects libcurl CURLMOPT_MAXCONNECTS. The default is -1.
---@field max_total_connections? integer is the maximum number of active connections. It affects libcurl CURLMOPT_MAX_TOTAL_CONNECTIONS. It is ignored if the curl version is less than 7.30. The default is 0, which allows libcurl to scale accordingly to easily handles count.

---@param options http.client.options
---@return http.client
function http.new(options) end

---@class http.client.request.options
---@field ca_file? string path to an SSL certificate file to verify the peer with.
---@field ca_path? string path to a directory holding one or more certificates to verify the peer with.
---@field headers? table<string,any>  table of HTTP headers.
---@field keepalive_idle? number delay, in seconds, that the operating system will wait while the connection is idle before sending keepalive probes. See also CURLOPT_TCP_KEEPIDLE and the note below about keepalive_interval.
---@field keepalive_interval? number the interval, in seconds, that the operating system will wait between sending keepalive probes. See also CURLOPT_TCP_KEEPINTVL. If both keepalive_idle and keepalive_interval are set, then Tarantool will also set HTTP keepalive headers: Connection:Keep-Alive and Keep-Alive:timeout=<keepalive_idle>. Otherwise Tarantool will send Connection:close.
---@field low_speed_limit? number  set the "low speed limit" – the average transfer speed in bytes per second that the transfer should be below during "low speed time" seconds for the library to consider it to be too slow and abort. See also CURLOPT_LOW_SPEED_LIMIT.
---@field low_speed_time? number  set the "low speed time" – the time that the transfer speed should be below the "low speed limit" for the library to consider it too slow and abort. See also CURLOPT_LOW_SPEED_TIME.
---@field max_header_name_len? integer the maximal length of a header name. If a header name is bigger than this value, it is truncated to this length. The default value is ‘32’.
---@field follow_location? boolean (Default: true) when the option is set to true (default) and the response has a 3xx code, the HTTP client will automatically issue another request to a location that a server sends in the Location header.
---@field no_proxy? string a comma-separated list of hosts that do not require proxies, or ‘*’, or ‘’. Set no_proxy = host [, host ...] to specify hosts that can be reached without requiring a proxy
---@field proxy? string a proxy server host or IP address, or ‘’. If proxy is a host or IP address, then it may begin with a scheme, for example https:// for an https proxy or http:// for an http proxy.
---@field proxy_port? integer  a proxy server port. The default is 443 for an https proxy and 1080 for a non-https proxy. See also CURLOPT_PROXYPORT.
---@field proxy_user_pwd? string a proxy server user name and/or password. Format: proxy_user_pwd = user_name: or proxy_user_pwd = :password or proxy_user_pwd = user_name:password
---@field ssl_cert? string  path to a SSL client certificate file. See also CURLOPT_SSLCERT.
---@field ssl_key? string  path to a private key file for a TLS and SSL client certificate. See also CURLOPT_SSLKEY.
---@field timeout? number (Default: 36586400100) number of seconds to wait for a curl API read request before timing out
---@field unix_socket? string a socket name to use instead of an Internet address, for a local connection. The Tarantool server must be built with libcurl 7.40 or later. See the second example later in this section.
---@field verbose? boolean  set on/off verbose mode.
---@field verify_host? boolean set on/off verification of the certificate’s name (CN) against host. See also CURLOPT_SSL_VERIFYHOST.
---@field verify_peer? boolean set on/off verification of the peer’s SSL certificate. See also CURLOPT_SSL_VERIFYPEER.
---@field accept_encoding? string enables automatic decompression of HTTP responses by setting the contents of the Accept-Encoding: header sent in an HTTP request and enabling decoding of a response when the Content-Encoding: header is received.

---@class http.response
---@field status integer HTTP response status
---@field reason string HTTP response status text
---@field headers table<string,any>  a Lua table with normalized HTTP headers
---@field body string? response body
---@field proto number protocol version

---Performs an HTTP request and, if there is a successful connection, will return a table with connection information.
---
---@param method string
---@param url string
---@param body? string
---@param opts http.client.request.options
---@return http.response
---@async
function http_client:request(method, url, body, opts) end

---Shortcut for `http_client:request("PATCH", url, body, opts)`
---
---@param url string
---@param body string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:patch(url, body, options) end

---Shortcut for `http_client:request("OPTIONS", url, nil, opts)`
---
---@param url string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:options(url, options) end

---Shortcut for `http_client:request("PUT", url, body, opts)`
---
---@param url string
---@param body string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:put(url, body, options) end

---Shortcut for `http_client:request("CONNECT", url, body, opts)`
---
---@param url string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:connect(url, options) end

---Shortcut for `http_client:request("DELETE", url, body, opts)`
---
---@param url string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:delete(url, options) end

---Shortcut for `http_client:request("POST", url, body, opts)`
---
---@param url string
---@param body string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:post(url, body, options) end

---Shortcut for `http_client:request("TRACE", url, body, opts)`
---
---@param url string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:trace(url, options) end

---Shortcut for `http_client:request("HEAD", url, body, opts)`
---
---@param url string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:head(url, options) end

---Shortcut for `http_client:request("GET", url, body, opts)`
---
---@param url string
---@param options http.client.request.options
---@return http.response
---@async
function http_client:get(url, options) end

---@class http.client.stat
---@field active_requests number number of currently executing requests
---@field sockets_added number total number of sockets added into an event loop
---@field sockets_deleted number total number of sockets sockets from an event loop
---@field total_requests number total number of requests
---@field http_200_responses number total number of requests which have returned code HTTP 200
---@field http_other_responses number total number of requests which have not returned code HTTP 200
---@field failed_requests number total number of requests which have failed including system errors, curl errors, and HTTP errors

---Returns a table with statistics.
---
---@return http.client.stat
function http_client:stat() end

---Performs an HTTP request and, if there is a successful connection, will return a table with connection information.
---
---@param method string
---@param url string
---@param body? string
---@param opts? http.client.request.options
---@return http.response
---@async
function http.request(method, url, body, opts)` end

---Shortcut for `http.request("PATCH", url, body, opts)`
---
---@param url string
---@param body string
---@param options? http.client.request.options
---@return http.response
---@async
function http.patch(url, body, options) end

---Shortcut for `http.request("OPTIONS", url, nil, opts)`
---
---@param url string
---@param options? http.client.request.options
---@return http.response
---@async
function http.options(url, options) end

---Shortcut for `http.request("PUT", url, body, opts)`
---
---@param url string
---@param body string
---@param options? http.client.request.options
---@return http.response
---@async
function http.put(url, body, options) end

---Shortcut for `http.request("CONNECT", url, body, opts)`
---
---@param url string
---@param options? http.client.request.options
---@return http.response
---@async
function http.connect(url, options) end

---Shortcut for `http.request("DELETE", url, body, opts)`
---
---@param url string
---@param options? http.client.request.options
---@return http.response
---@async
function http.delete(url, options) end

---Shortcut for `http.request("POST", url, body, opts)`
---
---@param url string
---@param body string
---@param options? http.client.request.options
---@return http.response
---@async
function http.post(url, body, options) end

---Shortcut for `http.request("TRACE", url, body, opts)`.
---
---@param url string
---@param options? http.client.request.options
---@return http.response
---@async
function http.trace(url, options) end

---Shortcut for `http.request("HEAD", url, body, opts)`.
---
---@param url string
---@param options? http.client.request.options
---@return http.response
---@async
function http.head(url, options) end

---Shortcut for `http.request("GET", url, body, opts)`.
---
---@param url string
---@param options? http.client.request.options
---@return http.response
---@async
function http.get(url, options) end

return http
