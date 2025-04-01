---@meta

---@class box.stat.default
---@field total number
---@field rps number

---@class box.stat.default_with_current: box.stat.default
---@field current number

---@class box.stat.net
---@field SENT box.stat.default sent bytes to iproto
---@field RECEIVED box.stat.default received bytes from iproto
---@field CONNECTIONS box.stat.default_with_current iproto connections statistics
---@field REQUESTS box.stat.default_with_current iproto requests statistics

---@class box.stat
---@field reset fun() # resets current statistics
---@field net fun(): box.stat.net
---@overload fun(): box.stat.info

---@class box.stat.info
---@field INSERT box.stat.default
---@field DELETE box.stat.default
---@field SELECT box.stat.default
---@field REPLACE box.stat.default
---@field UPDATE box.stat.default
---@field UPSERT box.stat.default
---@field CALL box.stat.default
---@field EVAL box.stat.default
---@field AUTH box.stat.default
---@field ERROR box.stat.default

---@type box.stat
box.stat = {}
