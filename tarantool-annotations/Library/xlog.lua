---@meta

---# Builtin `xlog` module.
---
---The xlog module contains one function: `pairs()`.
---
---It can be used to read Tarantool's [snapshot files](doc://index-box_persistence) or [write-ahead-log (WAL)](doc://internals-wal) files. Ade scription of the file format is in section [Data persistence and the WAL file format](doc://internals-data_persistence).
local xlog = {}

---Open a file, and allow iterating over one file entry at a time.
---
---Possible errors: File does not contain properly formatted snapshot or write-ahead-log information.
---
---**Example:**
---
---This will read the first write-ahead-log (WAL) file that was created in the [wal_dir](doc://cfg_basic-wal_dir) directory in our ["Getting started" exercises](doc://getting_started).
---
---Each result from `pairs()` is formatted with MsgPack so its structure can be specified with [__serialize](doc://msgpack-serialize).
---
--- ```lua
--- xlog = require('xlog')
--- t = {}
--- for k, v in xlog.pairs('00000000000000000000.xlog') do
---   table.insert(t, setmetatable(v, { __serialize = "map"}))
--- end
--- return t
--- ```
---
---The first lines of the result will look like:
---
--- ```tarantoolsession
--- (...)
--- ---
--- - - {'BODY':   {'space_id': 272, 'index_base': 1, 'key': ['max_id'],
---                 'tuple': [['+', 2, 1]]},
---      'HEADER': {'type': 'UPDATE', 'timestamp': 1477846870.8541,
---                 'lsn': 1, 'server_id': 1}}
---   - {'BODY':   {'space_id': 280,
---                  'tuple': [512, 1, 'tester', 'memtx', 0, {}, []]},
---      'HEADER': {'type': 'INSERT', 'timestamp': 1477846870.8597,
---                 'lsn': 2, 'server_id': 1}}
--- ```
---
---@param file string
---@return fun.iterator<any, nil>
function xlog.paris(file) end

return xlog
