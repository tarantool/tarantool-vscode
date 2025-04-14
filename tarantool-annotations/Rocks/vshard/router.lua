---@meta

---@class vshard.router
---@field name string Name of router
---@field current_cfg vshard.cfg The last passed configuration.
---@field connection_outdate_delay number Time to outdate old objects on reload.
---@field route_map table Bucket map cache.
---@field replicasets vshard.replicaset[] All known replicasets used for bucket re-balancing
---@field failover_fiber fiber to maintain replica connections
---@field master_search_fiber fiber Fiber to watch for master changes and find new masters
---@field discovery_fiber fiber Fiber to discovery buckets in background
---@field discovery_mode vshard.discovery_mode How discovery works. On - work infinitely. Off - no discovery
---@field total_bucket_count integer Bucket count stored on all replicasets
---@field known_bucket_count integer Timeout after which a ping is considered to be unacknowledged. Used by failover fiber to detect if a node is down
---@field failover_ping_timeout number Timeout to wait sync on storages. Used by sync() call when no timeout is specified
---@field sync_timeout number Flag whether router_cfg() is in progress.
---@field is_cfg_in_progress boolean Flag whether router_cfg() is finished.
---@field is_configured boolean Flag whether the instance is enabled manually. It is true by default for backward compatibility with old vshard.
---@field is_enabled boolean
---@field api_call_cache function Reference to the function-proxy to most of the public functions. It allows to avoid 'if's in each function by adding expensive conditional checks in one rarely used version of the wrapper and no checks into the other almost always used wrapper.
local router = {}

---@class vshard.router.bootstrap_options
---@field timeout? number A number of seconds before ending a bootstrap attempt as unsuccessful. Recreate the cluster in case of bootstrap timeout.
---@field if_not_bootstrapped? boolean  By default is set to false that means raise an error, when the cluster is already bootstrapped. True means consider an already bootstrapped cluster a success.

---Perform the initial cluster bootstrap and distribute all buckets across the replica sets.
---
---**Note:**
---
---To detect whether a cluster is bootstrapped, vshard looks for at least one bucket in the whole cluster.
---
---If the cluster was bootstrapped only partially (for example, due to an error during the first bootstrap), then it will be considered a bootstrapped cluster on a next bootstrap call with if_not_bootstrapped.
---
---So this is still a bad practice. Avoid calling `bootstrap()` multiple times.
---
---@param options vshard.router.bootstrap_options
function router.bootstrap(options) end

---Configure the database and start sharding for the specified `router` instance.
---
---**Throws exceptions:**
---
---* ROUTER_CFG_IS_IN_PROGRESS
---* Error injection: cfg
---* And others
---
---@param cfg vshard.cfg
---@return nil
function router.cfg(cfg) end


---Create a new router instance.
---
---vshard supports multiple routers in a single Tarantool instance.
---
---Each router can be connected to any vshard cluster, and multiple routers can be connected to the same cluster.
---
---**Throws exceptions:**
---
---* ROUTER_CFG_IS_IN_PROGRESS
---* Error injection
---* And others
---
---@param name string Router instance name. This name is used as a prefix in logs of the router and must be unique within the instance
---@param cfg vshard.cfg Configuration table
---@return vshard.router|nil # Router, instance, if created successfully; otherwise, nil and an error object
function router.new(name, cfg) end

---@alias vshard.call_mode
---| "read"  # target is the replica
---| "write" # target is the master

--TODO: Add client error, box error, socketerror

---Call the function identified by function-name on the shard storing the bucket identified by bucket_id.
---
---@param bucket_id integer A bucket identifier
---@param mode vshard.call_mode | {mode: vshard.call_mode, prefer_replica?: boolean, balance?: boolean } If `prefer_replica=true` is specified then the preferred target is one of the replicas, but the target is the master if there is no conveniently available replica. If `balance=true` then there is load balancing—reads are distributed over all the nodes in the replica set in round-robin fashion, with a preference for replicas if `prefer_replica=true` is also set.
---@param function_name string A function to execute
---@param argument_list? table An array of the function’s arguments
---@param options? net.box.call_options net.box options. `timeout` - if the router cannot identify a shard with the specified bucket_id, the operation will be repeated until the timeout is reached.
---@return any # Result of function_name on success or nil otherwise
---@return vshard.sharding_error? # Error on failure
function router.call(bucket_id, mode, function_name, argument_list, options) end

---Call the function identified by function-name on the shard storing the bucket identified by bucket_id, in read-only mode (similar to calling vshard.router.call with mode=’read’).
---
---@param bucket_id integer A bucket identifier
---@param function_name string A function to execute
---@param argument_list? table An array of the function’s arguments
---@param options? net.box.call_options net.box options. `timeout` - if the router cannot identify a shard with the specified bucket_id, the operation will be repeated until the timeout is reached.
---@return any # Result of function_name on success or nil otherwise
---@return vshard.sharding_error? # Error on failure
function router.callro(bucket_id, function_name, argument_list, options) end

---Call the function identified by function-name on the shard storing the bucket identified by bucket_id, in read-write mode (similar to calling vshard.router.call with mode=’write’).
---
---@param bucket_id integer A bucket identifier
---@param function_name string A function to execute
---@param argument_list? table An array of the function’s arguments
---@param options? net.box.call_options net.box options. `timeout` - if the router cannot identify a shard with the specified bucket_id, the operation will be repeated until the timeout is reached.
---@return any # Result of function_name on success or nil otherwise
---@return vshard.sharding_error? # Error on failure
function router.callrw(bucket_id, function_name, argument_list, options) end

---Call the function identified by `function-name` on the shard storing the bucket identified by `bucket_id`, in read-only mode (similar to calling vshard.router.call with `mode='read'`), with preference for a replica rather than a master (similar to calling vshard.router.call with `prefer_replica = true`)
---
---@param bucket_id integer A bucket identifier
---@param function_name string A function to execute
---@param argument_list? table An array of the function’s arguments
---@param options? net.box.call_options net.box options. `timeout` - if the router cannot identify a shard with the specified bucket_id, the operation will be repeated until the timeout is reached.
---@return any # Result of function_name on success or nil otherwise
---@return vshard.sharding_error? # Error on failure
function router.callre(bucket_id, function_name, argument_list, options) end

---This has the same effect as `vshard.router.call()` with mode parameter = `{mode='read', balance=true}`.
---
---@param bucket_id integer A bucket identifier
---@param function_name string A function to execute
---@param argument_list? table An array of the function’s arguments
---@param options? net.box.call_options net.box options. `timeout` - if the router cannot identify a shard with the specified bucket_id, the operation will be repeated until the timeout is reached.
---@return any # Result of function_name on success or nil otherwise
---@return vshard.sharding_error? # Error on failure
function router.callbro(bucket_id, function_name, argument_list, options) end


---This has the same effect as `vshard.router.call()` with mode parameter = `{mode='read', balance=true, prefer_replica=true}`.
---
---@param bucket_id integer A bucket identifier
---@param function_name string A function to execute
---@param argument_list? table An array of the function’s arguments
---@param options? net.box.call_options net.box options. `timeout` - if the router cannot identify a shard with the specified bucket_id, the operation will be repeated until the timeout is reached.
---@return any # Result of function_name on success or nil otherwise
---@return vshard.sharding_error? # Error on failure
function router.callbre(bucket_id, function_name, argument_list, options) end

---The function implements consistent map-reduce over the entire cluster.
---
---**Consistency means:**
---
---* All the data was accessible.
---* The data was not migrated between physical storages during the map requests execution.
---
---**The function can be helpful if you need to access:**
---
---* All the data in the cluster
---* A vast number of buckets scattered over the instances in case their individual `vshard.router.call()` takes up too much time
---
---@param function_name string A function to call on the storages (masters of all replica sets)
---@param argument_list? table An array of the function’s arguments
---@param options? net.box.call_options **Important:** Do not use a big timeout (longer than 1 minute, for instance). The router tries to block the bucket moves to another storage for the given timeout on all storages. On failure, the block remains for the entire timeout.
---@return table<vshard.uuid, table>|nil # A map with replica set UUIDs (keys) and results of the function_name (values).
---@return vshard.sharding_error? # Error object
---@return vshard.uuid? # Optional replica set UUID where the error occurred. UUID will not be returned if the error is not related to a particular replica set. For instance, the method fails if not all buckets were found, even if all replica sets were scanned successfully
function router.map_callrw(function_name, argument_list, options) end

---Return the replica set object for the bucket with the specified bucket id value
---@param bucket_id integer A bucket identifier
---@return vshard.replicaset # A replicaset object
function router.route(bucket_id) end

---Return all available replica set objects.
---
---@return table<vshard.uuid, vshard.replicaset> # A map of the following type: `{UUID = replicaset}`
function router.routeall() end

---Logs a warning when used because it is not consistent for cdata numbers
---
---In particular, it returns 3 different values for normal Lua numbers like 123, for unsigned long long cdata (like `123ULL`, or `ffi.cast('unsigned long long',123)`), and for signed long long cdata (like `123LL`, or `ffi.cast('long long', 123)`).
---
---@deprecated
function router.bucket_id(key) end

---Calculate the bucket id using a simple built-in hash function
---
---In particular, it returns 3 different values for normal Lua numbers like 123, for unsigned long long cdata (like 123ULL, or ffi.cast('unsigned long long',123)), and for signed long long cdata (like 123LL, or ffi.cast('long long', 123))
---
---For float and double cdata (`ffi.cast('float', number)`, `ffi.cast('double', number)`) these functions return different values even for the same numbers of the same floating point type. This is because `tostring()` on a floating point cdata number returns not the number, but a pointer at it. Different on each call
---
---@param key number|string|table A hash key. This can be any Lua object (number, table, string).
---@return integer bucket_id A bucket identifier
function router.bucket_id_strcrc32(key) end

---
---
---This function is safer than bucket_id_strcrc32. It takes a CRC32 from a MessagePack encoded value. That is, bucket id of integers does not depend on their Lua type. In case of a string key, it does not encode it into MessagePack, but takes a hash right from the string
---
---However it still may return different values for not equal floating point types. That is, `ffi.cast('float', number)` may be reflected into a bucket id not equal to `ffi.cast('double', number)`. This can’t be fixed, because a float value, even being casted to double, may have a garbage tail in its fraction.
---
---Floating point keys should not be used to calculate a bucket id, usually.
---
---Be very careful in case you store floating point types in a space. When data is returned from a space, it is cast to Lua number. And if that value had an empty fraction part, it will be treated as an integer by `bucket_id_mpcrc32()`. So you need to do explicit casts in such case
---
---@param key number|string|table A hash key. This can be any Lua object (number, table, string).
---@return integer bucket_id A bucket identifier
function router.bucket_id_mpcrc32(key) end

---Return the total number of buckets specified in `vshard.router.cfg()`.
---
---@return integer bucket_count The total number of buckets
function router.bucket_count() end

---Wait until the dataset is synchronized on replicas.
---
---@param timeout number A timeout, in seconds
---@return boolean?  # True if the dataset was synchronized successfully
---@return vshard.error? # Error explaining why the dataset cannot be synchronized.
function router.sync(timeout) end

---Force wakeup of the bucket discovery fiber.
function router.discovery_wakeup() end

---Turn on/off the background discovery fiber used by the router to find buckets.
---
---The method is good to enable/disable discovery after the router is already started, but discovery is enabled by default. You may want to never enable it even for a short time—then specify the discovery_mode option in the configuration. It takes the same values as `vshard.router.discovery_set(mode)`.
---You may decide to turn off discovery or make it once if you have many routers, or tons of buckets (hundreds of thousands and more), and you see that the discovery process consumes notable CPU % on routers and storages. In that case it may be wise to turn off the discovery when there is no rebalancing in the cluster. And turn it on for new routers, as well as for all routers when rebalancing is started
---@param mode vshard.discovery_mode working mode of a discovery fiber
function router.discovery_set(mode) end


---@alias vshard.router.status_info "available" | "unreachable" | "missing"

---@alias vshard.router.bucket_status_info "available_ro" | "available_rw" | "unavailable" | "unreachable"

---@class vshard.router.replica_info
---@field network_timeout number A timeout for the request. The value is updated automatically on each 10th successful request and each 2nd failed request.
---@field status status_info Status of the instance
---@field uuid vshard.uuid UUID of the instance
---@field uri string URI of the instance

---@class vshard.router.replicaset_info
---@field replica vshard.router.replica_info
---@field bucket vshard.router.bucket_info
---@field master vshard.router.replica_info

---@class vshard.router.bucket_info
---@field available_ro integer The number of buckets known to the router and available for read requests
---@field available_rw integer The number of buckets known to the router and available for read and write requests
---@field unavailable integer The number of buckets known to the router but unavailable for any requests
---@field unreachable integer The number of buckets whose replica sets are not known to the router


---Return information about each instance.
---
---@return {replicasets: table<vshard.uuid, vshard.router.replicaset_info>, bucket: vshard.router.bucket_info, status: integer, alerts: string[]}
function router.info() end

---Return information about each bucket.
---
---Since a bucket map can be huge, only the required range of buckets can be specified
---
---@param offset integer The offset in a bucket map of the first bucket to show
---@param limit integer The maximum number of buckets to show
---@return {uuid: vshard.uuid | "unknown", status: vshard.router.bucket_status_info}[]
function router.buckets_info(offset, limit) end

---Manually allow access to the router API, revert `vshard.router.disable()`.
---
---*Since vshard v.0.1.21.*
---
---It is cannot be used for enabling a router API that was automatically disabled due to a running configuration process.
function router.enable() end

---Manually restrict access to the router API.
---
---*Since vshard v.0.1.21.*
---
---When the API is disabled, all its methods throw a Lua error, except `vshard.router.cfg()`, `vshard.router.new()`, `vshard.router.enable()` and `vshard.router.disable()`. The error object’s name attribute is ROUTER_IS_DISABLED.
---
---The router is enabled by default. However, it is automatically and forcefully disabled until the configuration is finished, as accessing the router’s methods at that time is not safe.
---
---Manual disabling can be used, for example, if some preparatory work needs to be done after calling `vshard.router.cfg()` but before the router’s methods are available
---
---**Example:**
---
--- ```
--- vshard.router.disable()
--- vshard.router.cfg(...)
--- -- Some preparatory work here ...
--- vshard.router.enable()
--- -- vshard.router's methods are available now
--- ```
---
function router.disable() end

---Wake up master discovery fiber on demand.
---
---Automated master discovery works in its own fiber on a router, which is activated only if at least one replica set is configured to look for the master (the master parameter is set to auto). The fiber wakes up within a certain period. But it is possible to wake it up on demand by using this function.
---
---Manual fiber wakeup can help speed up tests for master change. Another use case is performing some actions with a router in the router console.
---
---The function does nothing if master search is not configured for any replica set.
function vshard.router.master_search_wakeup() end

---Search for the bucket in the whole cluster.
---
---If the bucket is not found, it is likely that it does not exist. The bucket might also be moved during rebalancing and currently is in the RECEIVING state.
---
---@param bucket_id integer A bucket identifier
---@return vshard.replicaset
---@return vshard.sharding_error?
function router.bucket_discovery(bucket_id) end

return router
