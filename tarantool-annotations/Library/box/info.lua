---@meta

---@class box.info.election: table
---@field state "leader" | "follower" | "candidate"
---@field vote integer ID of a node the current node votes for. If the value is 0, it means the node hasn't voted in the current term yet.
---@field leader integer Leader node ID in the current term. If the value is 0, it means the node doesn't know which node is the leader in the current term.
---@field term integer Current election term.

---@class box.info.cluster: table
---@field uuid string UUID of the replicaset this instance belong.

---@class box.info.synchro.queue: table
---@field owner integer ID of the replica that owns the synchronous transaction queue.
---@field term number Current queue term. It contains the term of the last PROMOTE request.
---@field len number The number of entries that are currently waiting in the queue.
---@field busy boolean The boolean value is true when the instance is processing or writing some system request that modifies the queue (for example, PROMOTE, CONFIRM, or ROLLBACK).

---@class box.info.syncho: table
---@field quorum number The resulting value of the `replication_synchro_quorum` configuration option.
---@field queue box.info.synchro.queue

---@class box.info.downstream: table
---appears (is not nil) with data about an instance that is following instance n or is intending to follow it
---@field status "follow" | "stopped "
---@field idle number The time (in seconds) since the last time that instance n sent events through the downstream replication.
---@field lag number The time difference between the local time at the master node, recorded when a particular transaction was written to the write ahead log, and the local time recorded when it receives an acknowledgement for this transaction from a replica.
---@field vclock integer[] May be the same as the current instance's vclock.
---@field message? string
---@field system_message? string

---@class box.info.upstream: table
---@field peer string Contains instances URI, for example `127.0.0.1:3302`.
---@field status "auth" | "connecting" | "disconnecting" | "disconnected" | "follow" | "stopped" | "sync"
---@field idle number The time (in seconds) since the last event was received. This is the primary indicator of replication health.
---@field lag number The time difference between the local time of instance n, recorded when the event was received, and the local time at another master recorded when the event was written to the write ahead log on that master.
---@field message? string Contains an error message in case of a degraded state, otherwise it is `nil`.

---@class box.info.replica: table
---@field id integer A short numeric identifier of instance n within the replica set.
---@field uuid string A globally unique identifier of instance n.
---@field lsn integer A log sequence number (LSN) for the latest entry in instance n's write ahead log (WAL).
---@field upstream? box.info.upstream
---@field downstream? box.info.downstream

---# Builtin `box.info` submodule
---
---The `box.info` submodule provides access to information about a running Tarantool instance.
---
---@class box.info: table
---@field id integer A short numeric identifier of instance n within the replica set. This value is stored in the box.space._cluster system space.
---@field uuid string A globally unique identifier of instance n.
---@field pid integer A process ID.
---@field uptime integer A number of seconds since the instance started.
---@field status "unconfigured" | "running" | "loading" | "orphan" | "hot_standby" 
---@field lsn integer A log sequence number (LSN) for the latest entry in instance n's write ahead log (WAL).
---@field version string A Tarantool version number.
---@field ro boolean Is `true` if the instance is in "read-only" mode.
---@field public package string
---@field vclock integer[] A table with the vclock values of all instances in a replica set which have made data changes.
---@field replication table<integer,box.info.replica>
---@field election box.info.election Shows the current state of a replica set node regarding leader election.
---@field signature integer The sum of all lsn values from each vector clock (vclock) for all instances in the replica set.
---@field cluster box.info.cluster
---@field ro_reason string
---@field synchro table
---@overload fun(): box.info
box.info = {}

---@class box.info.memory
---@field cache integer A number of bytes used for caching user data. The memtx storage engine does not require a cache, so in fact this is the number of bytes in the cache for the tuples stored for the vinyl storage engine.
---@field data integer A number of bytes used for storing user data (the tuples) with the memtx engine and with level 0 of the vinyl engine, without taking memory fragmentation into account.
---@field index integer A number of bytes used for indexing user data, including memtx and vinyl memory tree extents, the vinyl page index, and the vinyl bloom filters.
---@field lua integer A number of bytes used for Lua runtime.
---@field net integer A number of bytes used for network input/output buffers.
---@field tx integer A number of bytes in use by active transactions. For the vinyl storage engine, this is the total size of all allocated objects (struct txv, struct vy_tx, struct vy_read_interval) and tuples pinned for those objects.

---Get information about memory usage for the current instance.
---
---**Note:**
---
---To get a picture of the vinyl subsystem, use [box.stat.vinyl()](lua://box.stat.vinyl) instead.
---
---@return box.info.memory
function box.info.memory() end

---@class box.info.gc.checkpoint: table
---@field references table[] A list of references to a checkpoint.
---@field vclock integer[] A checkpoint's vclock value.
---@field signature integer A sum of a checkpoint's vclock's components.

---@class box.info.gc: table
---@field vclock integer[] The garbage collector's vclock.
---@field signature integer The sum of the garbage collector's checkpoint's components.
---@field checkpoint_is_in_progress boolean `true` if a checkpoint is in progress, otherwise `false`.
---@field consumers table[] A list of users whose requests might affect the garbage collector.
---@field checkpoints box.info.gc.checkpoint[] A list of preserved checkpoints.

---Get information about the [Tarantool garbage collector](doc://configuration_persistence_garbage_collector).
---
---The garbage collector compares vclock (see [vector clock](doc://replication-vector)) values of users and checkpoints, so a look at `box.info.gc()` may show why the garbage collector has not removed old WAL files, or show what it may soon remove.
---
---@return box.info.gc
function box.info.gc() end
