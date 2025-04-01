---@meta

---# Builtin `box.ctl` submodule
---
---The `wait_ro` (wait until read-only) and `wait_rw` (wait until read-write) functions are useful during server initialization.
---
---To see whether a function is already in read-only or read-write mode, check :ref:`box.info.ro <box_introspection-box_info>`.
---
---A particular use is for :doc:`box.once() </reference/reference_lua/box_once>`.
---
---For example, when a replica is initializing, it may call a `box.once()` function while the server is still in read-only mode, and fail to make changes that are necessary only once before the replica is fully initialized.
---
---This could cause conflicts between a master and a replica if the master is in read-write mode and the replica is in read-only mode. Waiting until "read only mode = false" solves this problem.
box.ctl = {}

---Wait, then choose new replication leader.
---
---*Since 2.6.2*
---*Renamed in 2.6.3*
---
---For [synchronous transactions](doc://repl_sync) it is possible that a new leader will be chosen but the transactions of the old leader have not been completed. Therefore to finalize the transaction, the function `box.ctl.promote()` should be called, as mentioned in the notes for
---[leader election](doc://repl_leader_elect_important).
---
---The old name for this function is `box.ctl.clear_synchro_queue()`.
---
---The [election state](lua://box.info.election) should change to `leader`.
function box.ctl.promote() end

---Revoke the leader role from the instance.
---
---*Since 2.10.0*
---
---On [synchronous transaction queue owner](lua://box.info.synchro), the function works in the following way:
---* If [`box.cfg.election_mode`](doc://cfg_replication-election_mode) is `off`, the function writes a `DEMOTE` request to WAL. The `DEMOTE` request clears the ownership of the synchronous transaction queue, while the `PROMOTE` request assigns it to a new instance.
---* If [`box.cfg.election_mode`](doc://cfg_replication-election_mode) is enabled in any mode, then the function makes the instance start a new term and give up the leader role.
---
---On instances that are not queue owners, the function does nothing and returns immediately.
function box.ctl.demote() end

---Wait until `box.info.ro` is false.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> n = box.ctl.wait_ro(0.1)
--- ---
--- ...
--- ```
---
---@async
---@param timeout? number
function box.ctl.wait_rw(timeout) end

---Wait until `box.info.ro` is true.
---
---**Example:**
---
--- ```tarantoolsession
--- tarantool> box.info().ro
--- ---
--- - false
--- ...
---
--- tarantool> n = box.ctl.wait_ro(0.1)
--- ---
--- - error: timed out
--- ...
--- ```
---
---@async
---@param timeout? number
function box.ctl.wait_ro(timeout) end

---Create a shutdown trigger.
---
---The `trigger-function` will be executed whenever [`os.exit()`](os.exit) happens, or when the server is shut down after receiving a `SIGTERM` or `SIGINT` or `SIGHUP` signal (but not after `SIGSEGV` or `SIGABORT` or any signal that causes immediate program termination).
---
---If the parameters are (nil, old-trigger-function), then the old trigger is deleted.
---
---If you want to set a timeout for this trigger, use the [`set_on_shutdown_timeout`](lua://box.ctl.on_shutdown_timeout) function.
---
---@param trigger_function fun()
---@param old_trigger_function? fun()
---@return fun()? created_trigger
function box.ctl.on_shutdown(trigger_function, old_trigger_function) end

---Create a trigger executed when leader election changes replica state.
---
---* Since 2.10.0 *
---
---Create a [trigger](doc://triggers) executed every time the current state of a replica set node in regard to [leader election](doc://repl_leader_elect) changes.
---
---The current state is available in the [`box.info.election`](lua://box.info.election) table.
---
---The trigger doesn't accept any parameters.
---
---You can see the changes in `box.info.election` and [`box.info.synchro`](box.info.synchro).
---
---@param trigger function
function box.ctl.on_election(trigger) end

return box.ctl
