---@meta

local uri = {}

---@class uri
---@field fragment? string string after #
---@field host? string host (same as Host header in HTTP)
---@field ipv4? string ipv4 address if was parsed
---@field ipv6? string ipv6 address if was parsed
---@field login? string login as for basic auth if was parsed
---@field password? string password as for basic auth if was parsed
---@field path? string path in HTTP URI if was parsed
---@field query? table<string,string[]> query of arguments, values are a list of strings
---@field scheme? string scheme
---@field service? string port if was given
---@field unix? string path to unix socket if was parsed

---Parse a URI string into components.
---
---**Example:**
---
--- ```lua
--- local uri = require('uri')
--- 
--- parsed_uri = uri.parse('https://www.tarantool.io/doc/latest/reference/reference_lua/http/#api-reference')
--- --[[
--- ---
--- - host: www.tarantool.io
---   fragment: api-reference
---   scheme: https
---   path: /doc/latest/reference/reference_lua/http/
--- ...
--- --]]
--- ```
---
---@param uri_string string a Uniform Resource Identifier
---@return uri
function uri.parse(uri_string) end

---Construct a URI from the specified components.
---
---**Example:**
---
--- ```lua
--- formatted_uri = uri.format({ scheme = 'https',
---                              host = 'www.tarantool.io',
---                              path = '/doc/latest/reference/reference_lua/http/',
---                              fragment = 'api-reference' })
--- --[[
--- ---
--- - https://www.tarantool.io/doc/latest/reference/reference_lua/http/#api-reference
--- ...
--- --]]
--- ```
---
---@param uri_format uri a series of name=value pairs, one for each component
---@param include_password boolean? If this is supplied and is true, then the password component is rendered in clear text, otherwise it is omitted.
---@return string
function uri.format(uri_format, include_password) end

---Encode a string using the specified encoding options.
---
---*Since 2.11.0*
---
---**Examples:**
---
--- ```lua
--- escaped_string = uri.escape('C++')
--- --[[
--- ---
--- - C%2B%2B
--- ...
--- --]]
--- ```
---
--- ```lua
--- escaped_string_url_enc = uri.escape('John Smith', uri.FORM_URLENCODED)
--- --[[
--- ---
--- - John+Smith
--- ...
--- --]]
--- ```
---
--- ```lua
--- local escape_opts = {
---     plus = true,
---     unreserved = uri.unreserved("a-z")
--- }
--- escaped_string_custom = uri.escape('Hello World', escape_opts)
--- --[[
--- ---
--- - '%48ello+%57orld'
--- ...
--- --]]
--- ```
---
---@param str string
---@param uri_encoding_opts uri.encoding_opt
---@return string
function uri.escape(str, uri_encoding_opts) end

---Decode a string using the specified encoding options.
---
---*Since 2.11.0*
---
--- By default, `uri.escape()` uses encoding options defined by the [`uri.RFC3986`](lua://uri.RFC3986) table.
---
--- If required, you can customize encoding options using the `uri_encoding_opts` optional parameter, for example:
--- * Pass the predefined set of options targeted for encoding a specific URI part (for example, [`uri.PATH`](lua://uri.PATH) or [`uri.QUERY`](lua://lua.QUERY)).
--- * Pass custom encoding options using the [uri.encoding_opts](uri.encoding_opts) object.
---
---**Examples:**
---
--- ```lua
--- unescaped_string = uri.unescape('C%2B%2B')
--- --[[
--- ---
--- - C++
--- ...
--- --]]
--- ```
---
--- ```lua
--- unescaped_string_url_enc = uri.unescape('John+Smith', uri.FORM_URLENCODED)
--- --[[
--- ---
--- - John Smith
--- ...
--- --]]
--- ```
---
--- ```lua
--- local escape_opts = {
---     plus = true,
---     unreserved = uri.unreserved("a-z")
--- }
--- unescaped_string_custom = uri.unescape('%48ello+%57orld', escape_opts)
--- --[[
--- ---
--- - Hello World
--- ...
--- --]]
--- ```
---
---@param str string
---@param uri_encoding_opts uri.encoding_opt
---@return string
function uri.unescape(str, uri_encoding_opts) end

---@class uri.encoding_opt

---Encoding options that use unreserved symbols defined in RFC 3986
---
---@type uri.encoding_opt
uri.RFC3986 = nil

---Options used to encode the `path` URI component
---
---@type uri.encoding_opt
uri.PATH = nil

---Options used to encode specific `path` parts
---
---@type uri.encoding_opt
uri.PATH_PART = nil

---Options used to encode the `query` URI component
---
---@type uri.encoding_opt
uri.QUERY = nil

--- Options used to encode specific `query` parts
---
---@type uri.encoding_opt
uri.QUERY_PART = nil

---Options used to encode the `fragment` URI component
---
---@type uri.encoding_opt
uri.FRAGMENT = nil

---Options used to encode `application/x-www-form-urlencoded` form parameters
---
---@type uri.encoding_opt
uri.FORM_URLENCODED = nil

-- TODO: uri encoding options

---@alias uri_like uri | string

return uri
