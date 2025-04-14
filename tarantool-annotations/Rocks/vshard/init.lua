---@meta

---# Rock `vshard`
---
---The `vshard` module introduces an advanced sharding feature based on the concept of [virtual buckets](doc://vshard-vbuckets) and enables horizontal scaling in Tarantool.
---
---To learn how sharding works in Tarantool, refer to the [Sharding](doc://sharding) page.
---
---You can also check out the [Quick start guide](doc://vshard-quick-start) -- or dive into the `vshard` reference.
local vshard = {
    router = require('vshard.router'),
    --storage = require('vshard.storage'),
    consts = require('vshard.consts'),
    error = require('vshard.error'),
}

return vshard
