---@meta

---*Documentation is not provided yet.*
---
---@class vshard.storage
local storage = {}

---Configure the database and start sharding for the specified `storage` instance.
---
---@param cfg vshard.cfg a `storage` configuration
---@param name string instance uuid
function storage.cfg(cfg, name) end

---Return information about the storage instance.
---
---*Since vshard v.0.1.22*, the function also accepts options, which can be used to get additional information.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> vshard.storage.info()
--- ---
--- - replicasets:
---   c862545d-d966-45ff-93ad-763dce4a9723:
---   uuid: c862545d-d966-45ff-93ad-763dce4a9723
---   master:
---   uri: admin@localhost:3302
---   1990be71-f06e-4d9a-bcf9-4514c4e0c889:
---   uuid: 1990be71-f06e-4d9a-bcf9-4514c4e0c889
---   master:
---   uri: admin@localhost:3304
---   bucket:
---   receiving: 0
---   active: 15000
---   total: 15000
---   garbage: 0
---   pinned: 0
---   sending: 0
---   status: 0
---   replication:
---   status: master
---   alerts: []
---   ...
--- ```
---
---@param opts { with_services: boolean } options
function storage.info(opts) end

---*Documentation is not provided yet.*
function storage.call(bucket_id, mode, function_name, argument_list) end

---*Documentation is not provided yet.*
function storage.sync(timeout) end

---*Documentation is not provided yet.*
function storage.bucket_pin(bucket_id) end

---*Documentation is not provided yet.*
function storage.bucket_unpin(bucket_id) end

---*Documentation is not provided yet.*
function storage.bucket_ref(bucket_id, mode) end

---*Documentation is not provided yet.*
function storage.bucket_refro() end

---*Documentation is not provided yet.*
function storage.bucket_refrw() end

---*Documentation is not provided yet.*
function storage.bucket_unref(bucket_id, mode) end

---*Documentation is not provided yet.*
function storage.bucket_unrefro() end

---*Documentation is not provided yet.*
function storage.bucket_unrefrw() end

---*Documentation is not provided yet.*
function storage.find_garbage_bucket(bucket_index, control) end

---*Documentation is not provided yet.*
function storage.rebalancer_disable() end

---*Documentation is not provided yet.*
function storage.rebalancer_enable() end

---*Documentation is not provided yet.*
function storage.is_locked() end

---*Documentation is not provided yet.*
function storage.rebalancing_is_in_progress() end

---*Documentation is not provided yet.*
function storage.buckets_info() end

---*Documentation is not provided yet.*
function storage.buckets_count() end

---*Documentation is not provided yet.*
function storage.sharded_spaces() end

---*Documentation is not provided yet.*
function storage.bucket_stat(bucket_id) end

---*Documentation is not provided yet.*
function storage.bucket_recv(bucket_id, from, data) end

---*Documentation is not provided yet.*
function storage.bucket_delete_garbage(bucket_id) end

---*Documentation is not provided yet.*
function storage.bucket_collect(bucket_id) end

---*Documentation is not provided yet.*
function storage.bucket_force_create(first_bucket_id, count) end

---*Documentation is not provided yet.*
function storage.bucket_force_drop(bucket_id, to) end

---*Documentation is not provided yet.*
function storage.bucket_send(bucket_id, to) end

---*Documentation is not provided yet.*
function storage.buckets_discovery() end

---*Documentation is not provided yet.*
function storage.rebalancer_request_state() end

return storage
