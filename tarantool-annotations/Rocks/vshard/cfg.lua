---@meta

---@alias vshard.uuid string

---@alias vshard.cfg.replica {uri: string|number|table, listen: string|number|table?, name: string?, zone: string|integer?, master: boolean?}

---@alias vshard.cfg.replicaset {replicas: replica[], weight: table?, lock: boolean?, master: UUID?}

---@alias vshard.discovery_mode
---| "on" # Discovery fiber works during all the lifetime of the router. Even after all buckets are discovered, it will still come to storages and download their buckets with some big period (DISCOVERY_IDLE_INTERVAL). This is useful if the bucket topology changes often and the number of buckets is not big. The router will keep its route table up to date even when no requests are processed.
---| "off" # Discovery is disabled completely.
---| "once" # Discovery starts and finds the locations of all buckets, and then the discovery fiber is terminated. This is good for a large bucket count and for clusters, where rebalancing is rare.

---@class vshard.cfg: box.cfg
---@field sharding table<vshard.uuid, vshard.cfg.replicaset> (Default: false) A field defining the logical topology of the sharded Tarantool cluster.
---@field bucket_count integer (Default: 3000) The total number of buckets in a cluster. This number should be several orders of magnitude larger than the potential number of cluster nodes, considering potential scaling out in the foreseeable future.
---@field weights? table<integer, table<integer,integer>>|boolean (Default: false) A field defining the configuration of relative weights for each zone pair in a replica set. See the Replica weights section.
---@field shard_index? string|integer (Default: "bucket_id") Name or id of a TREE index over the bucket id. Spaces without this index do not participate in a sharded Tarantool cluster and can be used as regular spaces if needed. It is necessary to specify the first part of the index, other parts are optional.
---@field collect_bucket_garbage_interval? number (DEPRECATED) (Default: 0.5) The interval between garbage collector actions, in seconds.
---@field collect_lua_garbage? boolean (DEPRECATED) (Default: false) If set to true, the Lua collectgarbage() function is called periodically.
---@field sync_timeout? number (Default: 1) Timeout to wait for synchronization of the old master with replicas before demotion. Used when switching a master or when manually calling the sync() function.
---@field rebalancer_disbalance_threshold? number (Default: 1) A maximum bucket disbalance threshold, in percent. The threshold is calculated for each replica set using the following formula: (etalon_bucket_count - real_bucket_count) / etalon_bucket_count * 100
---@field rebalancer_max_receiving? integer (Default: 100) The maximum number of buckets that can be received in parallel by a single replica set. This number must be limited, because when a new replica set is added to a cluster, the rebalancer sends a very large amount of buckets from the existing replica sets to the new replica set. This produces a heavy load on the new replica set.
---@field rebalancer_max_sending? integer (Default: 1) The degree of parallelism for parallel rebalancing. Works for storages only, ignored for routers. The maximum value is 15.
---@field discovery_mode? vshard.discovery_mode (Default: "on") A mode of a bucket discovery fiber: on/off/once
---@field connection_outdate_delay? number
---@field failover_ping_timeout? number
---@field sched_ref_quota? number
---@field sched_move_quota? number
---@field zone? string|integer
