---@meta
--luacheck: ignore

local error = {}

---@alias vshard.err_code
---| 1 #  WRONG_BUCKET
---| 2 #  NON_MASTER
---| 3 #  BUCKET_ALREADY_EXISTS
---| 4 #  NO_SUCH_REPLICASET
---| 5 #  MOVE_TO_SELF
---| 6 #  MISSING_MASTER
---| 7 #  TRANSFER_IS_IN_PROGRESS
---| 8 #  UNREACHABLE_REPLICASET
---| 9 #  NO_ROUTE_TO_BUCKET
---| 10 # NON_EMPTY
---| 11 # UNREACHABLE_MASTER
---| 12 # OUT_OF_SYNC
---| 13 # HIGH_REPLICATION_LAG
---| 14 # UNREACHABLE_REPLICA
---| 15 # LOW_REDUNDANCY
---| 16 # INVALID_REBALANCING
---| 17 # SUBOPTIMAL_REPLICA
---| 18 # UNKNOWN_BUCKETS
---| 19 # REPLICASET_IS_LOCKED
---| 20 # OBJECT_IS_OUTDATED
---| 21 # ROUTER_ALREADY_EXISTS
---| 22 # BUCKET_IS_LOCKED
---| 23 # INVALID_CFG
---| 24 # BUCKET_IS_PINNED
---| 25 # TOO_MANY_RECEIVING
---| 26 # STORAGE_IS_REFERENCED
---| 27 # STORAGE_REF_ADD
---| 28 # STORAGE_REF_USE
---| 29 # STORAGE_REF_DEL
---| 30 # BUCKET_RECV_DATA_ERROR
---| 31 # MULTIPLE_MASTERS_FOUND
---| 32 # REPLICASET_IN_BACKOFF
---| 33 # STORAGE_IS_DISABLED
---| 34 # BUCKET_IS_CORRUPTED
---| 35 # ROUTER_IS_DISABLED
---| 36 # BUCKET_GC_ERROR
---| 37 # STORAGE_CFG_IS_IN_PROGRESS
---| 38 # ROUTER_CFG_IS_IN_PROGRESS

---@alias vshard.sharding_error
---| vshard.error.wrong_bucket
---| vshard.error.non_master
---| vshard.error.no_such_replicaset
---| vshard.error.move_to_self
---| vshard.error.missing_master
---| vshard.error.transfer_is_in_progress
---| vshard.error.unreachable_replicaset
---| vshard.error.no_route_to_bucket
---| vshard.error.non_empty
---| vshard.error.unreachable_master
---| vshard.error.out_of_sync
---| vshard.error.high_replication_lag
---| vshard.error.unreachable_replica
---| vshard.error.low_redundancy
---| vshard.error.invalid_rebalancing
---| vshard.error.suboptimal_replica
---| vshard.error.unknown_buckets
---| vshard.error.replicaset_is_locked
---| vshard.error.object_is_outdated
---| vshard.error.bucket_is_locked
---| vshard.error.invalid_cfg
---| vshard.error.bucket_is_pinned
---| vshard.error.too_many_receiving
---| vshard.error.storage_is_referenced
---| vshard.error.storage_ref_add
---| vshard.error.storage_ref_use
---| vshard.error.storage_ref_del
---| vshard.error.bucket_recv_data_error
---| vshard.error.multiple_masters_found
---| vshard.error.replicaset_in_backoff
---| vshard.error.storage_is_disabled
---| vshard.error.bucket_is_corrupted
---| vshard.error.router_is_disabled
---| vshard.error.bucket_gc_error
---| vshard.error.storage_cfg_is_in_progress
---| vshard.error.router_cfg_is_in_progress

--- It is created on sharding errors like
--- replicaset unavailability, master absence etc. It has type =
--- 'ShardingError'.
---@class vshard.error
---@field message string
---@field type "ShardingError"
---@field code vshard.err_code
---@field name string

---@class vshard.error.wrong_bucket: vshard.error
---@field name "WRONG_BUCKET"
---@field code 1
---@field bucket_id number
---@field reason string
---@field destination string

---@class vshard.error.non_master: vshard.error
---@field name "NON_MASTER"
---@field code 2
---@field replica_uuid UUID
---@field replicaset_uuid UUID
---@field master_uuid UUID

---@class vshard.error.bucket_already_exists: vshard.error
---@field name "BUCKET_ALREADY_EXISTS"
---@field code 3
---@field bucket_id number

---@class vshard.error.no_such_replicaset: vshard.error
---@field name "NO_SUCH_REPLICASET"
---@field code 4
---@field replicaset_uuid UUID

---@class vshard.error.move_to_self: vshard.error
---@field name "MOVE_TO_SELF"
---@field code 5
---@field bucket_id number
---@field replicaset_uuid UUID

---@class vshard.error.missing_master: vshard.error
---@field name "MISSING_MASTER"
---@field code 6
---@field replicaset_uuid UUID

---@class vshard.error.transfer_is_in_progress: vshard.error
---@field name "TRANSFER_IS_IN_PROGRESS"
---@field code 7
---@field destination string
---@field bucket_id number

---@class vshard.error.unreachable_replicaset: vshard.error
---@field name "UNREACHABLE_REPLICASET"
---@field code 8
---@field unreachable_uuid UUID
---@field bucket_id number

---@class vshard.error.no_route_to_bucket: vshard.error
---@field name "NO_ROUTE_TO_BUCKET"
---@field code 9
---@field bucket_id number

---@class vshard.error.non_empty: vshard.error
---@field name "NON_EMPTY"
---@field code 10

---@class vshard.error.unreachable_master: vshard.error
---@field name "UNREACHABLE_MASTER"
---@field code 11
---@field reason string
---@field uuid UUID

---@class vshard.error.out_of_sync: vshard.error
---@field name "OUT_OF_SYNC"
---@field code 12

---@class vshard.error.high_replication_lag: vshard.error
---@field name "HIGH_REPLICATION_LAG"
---@field code 13
---@field lag number

---@class vshard.error.unreachable_replica: vshard.error
---@field name "UNREACHABLE_REPLICA"
---@field code 14
---@field unreachable_uuid UUID

---@class vshard.error.low_redundancy: vshard.error
---@field name "LOW_REDUNDANCY"
---@field code 15

---@class vshard.error.invalid_rebalancing: vshard.error
---@field name "INVALID_REBALANCING"
---@field code 16

---@class vshard.error.suboptimal_replica: vshard.error
---@field name "SUBOPTIMAL_REPLICA"
---@field code 17

---@class vshard.error.unknown_buckets: vshard.error
---@field name "UNKNOWN_BUCKETS"
---@field code 18
---@field not_discovered_cnt number

---@class vshard.error.replicaset_is_locked: vshard.error
---@field name "REPLICASET_IS_LOCKED"
---@field code 19

---@class vshard.error.object_is_outdated: vshard.error
---@field name "OBJECT_IS_OUTDATED"
---@field code 20

---@class vshard.error.router_already_exists: vshard.error
---@field name "ROUTER_ALREADY_EXISTS"
---@field code 21
---@field router_name string

---@class vshard.error.bucket_is_locked: vshard.error
---@field name "BUCKET_IS_LOCKED"
---@field code 22
---@field bucket_id number

---@class vshard.error.invalid_cfg: vshard.error
---@field name "INVALID_CFG"
---@field code 23
---@field reason string

---@class vshard.error.bucket_is_pinned: vshard.error
---@field name "BUCKET_IS_PINNED"
---@field code 24
---@field bucket_id number

---@class vshard.error.too_many_receiving: vshard.error
---@field name "TOO_MANY_RECEIVING"
---@field code 25

---@class vshard.error.storage_is_referenced: vshard.error
---@field name "STORAGE_IS_REFERENCED"
---@field code 26

---@class vshard.error.storage_ref_add: vshard.error
---@field name "STORAGE_REF_ADD"
---@field code 27
---@field reason string

---@class vshard.error.storage_ref_use: vshard.error
---@field name "STORAGE_REF_USE"
---@field code 28
---@field reason string

---@class vshard.error.storage_ref_del: vshard.error
---@field name "STORAGE_REF_DEL"
---@field code 29
---@field reason string

---@class vshard.error.bucket_recv_data_error: vshard.error
---@field name "BUCKET_RECV_DATA_ERROR"
---@field code 30
---@field bucket_id number
---@field space string
---@field tuple table
---@field reason string

---@class vshard.error.multiple_masters_found: vshard.error
---@field name "MULTIPLE_MASTERS_FOUND"
---@field code 31
---@field replicaset_uuid UUID
---@field master1 string
---@field master2 string

---@class vshard.error.replicaset_in_backoff: vshard.error
---@field name "REPLICASET_IN_BACKOFF"
---@field code 32
---@field replicaset_uuid UUID
---@field error table

---@class vshard.error.storage_is_disabled: vshard.error
---@field name "STORAGE_IS_DISABLED"
---@field code 33

--- That is similar to WRONG_BUCKET, but the latter is not critical. It
--- usually can be retried. Corruption is a critical error, it requires
--- more attention.
---@class vshard.error.bucket_is_corrupted: vshard.error
---@field name "BUCKET_IS_CORRUPTED"
---@field code 34
---@field reason string

---@class vshard.error.router_is_disabled: vshard.error
---@field name "ROUTER_IS_DISABLED"
---@field code 35
---@field reason string

---@class vshard.error.bucket_gc_error: vshard.error
---@field name "BUCKET_GC_ERROR"
---@field code 36
---@field reason string

---@class vshard.error.storage_cfg_is_in_progress: vshard.error
---@field name "STORAGE_CFG_IS_IN_PROGRESS"
---@field code 37

---@class vshard.error.router_cfg_is_in_progress: vshard.error
---@field name "ROUTER_CFG_IS_IN_PROGRESS"
---@field code 38
---@field router_name string

error.code = {
    WRONG_BUCKET = 1,
    NON_MASTER = 2,
    BUCKET_ALREADY_EXISTS = 3,
    NO_SUCH_REPLICASET = 4,
    MOVE_TO_SELF = 5,
    MISSING_MASTER = 6,
    TRANSFER_IS_IN_PROGRESS = 7,
    UNREACHABLE_REPLICASET = 8,
    NO_ROUTE_TO_BUCKET = 9,
    NON_EMPTY = 10,
    UNREACHABLE_MASTER = 11,
    OUT_OF_SYNC = 12,
    HIGH_REPLICATION_LAG = 13,
    UNREACHABLE_REPLICA = 14,
    LOW_REDUNDANCY = 15,
    INVALID_REBALANCING = 16,
    SUBOPTIMAL_REPLICA = 17,
    UNKNOWN_BUCKETS = 18,
    REPLICASET_IS_LOCKED = 19,
    OBJECT_IS_OUTDATED = 20,
    ROUTER_ALREADY_EXISTS = 21,
    BUCKET_IS_LOCKED = 22,
    INVALID_CFG = 23,
    BUCKET_IS_PINNED = 24,
    TOO_MANY_RECEIVING = 25,
    STORAGE_IS_REFERENCED = 26,
    STORAGE_REF_ADD = 27,
    STORAGE_REF_USE = 28,
    STORAGE_REF_DEL = 29,
    BUCKET_RECV_DATA_ERROR = 30,
    MULTIPLE_MASTERS_FOUND = 31,
    REPLICASET_IN_BACKOFF = 32,
    STORAGE_IS_DISABLED = 33,
    BUCKET_IS_CORRUPTED = 34,
    ROUTER_IS_DISABLED = 35,
    BUCKET_GC_ERROR = 36,
    STORAGE_CFG_IS_IN_PROGRESS = 37,
    ROUTER_CFG_IS_IN_PROGRESS = 38,
}

---Unpacking and and adding serialization meta table to json
---
---@param err box.error
---@return box.error
function error.box(err) end

---Construct an vshard error.
---
---@param code vshard.err_code Vshard error code
---@param ... any From `error_message_template` `args` field. Caller have to pass at least as many arguments as `msg` field requires.
---@return vshard.error
function error.vshard(code, ...) end

---Convert error object from pcall to lua, box or vshard error object.
---
---@param err any
---@return vshard.error | box.error
function error.make(err) end


---Restore an error object from its string serialization.
---
---@param err_str string
---@return vshard.error
function error.from_string(err_str) end

---Make alert message.
---
---@param code number
---@param ... any
---@return table
function error.alert(code, ...) end

---Create a timeout error object.
---
---@return box.error
function error.timeout() end

return error
