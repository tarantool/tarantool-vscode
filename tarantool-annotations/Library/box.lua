---@meta

---# Builtin `box` module
---
---As well as executing Lua chunks or defining your own functions, you can exploit Tarantool's storage functionality with the `box` module and its submodules.
---
---Every submodule contains one or more Lua functions. A few submodules contain members as well as functions. The functions allow data definition (create alter drop), data manipulation (insert delete update upsert select replace), an introspection (inspecting contents of spaces, accessing server configuration).
---
---To catch errors that functions in `box` submodules may throw, use `pcall()`.
box = {}

--- If a transaction is in progress (for example the user has called [`box.begin()`](lua://box.begin) and has not yet called either [`box.begin()`](lua://box.begin) or [`box.rollback()`](lua://box.rollback), return `true`. Otherwise return `false`.
---
---@return boolean is_in_txn
function box.is_in_txn() end

---@alias box.txn_isolation
---| 'best-effort'
---| 'read-committed'
---| 'read-confirmed'
---| 'linearizable'

---@class box.begin_options
---@field txn_isolation? box.txn_isolation the transaction isolation level (default: best-effort)
---@field timeout? (in_seconds) Number a timeout, after which the transaction is rolled back

---Begin the transaction.
---
---Disable implicit yields until the transaction ends.
---Signal that writes to the write-ahead log will be deferred until the transaction ends.
---In effect the fiber which executes `box.begin()` is starting an "active multi-request transaction", blocking all other fibers.
---
---**Possible errors:**
---* Error if this operation is not permitted because there is already an active transaction.
---* Error if for some reason memory cannot be allocated.
---* Error and abort the transaction if the timeout is exceeded.
---
---@param opts? box.begin_options
function box.begin(opts) end

---End the transaction, and make all its data-change operations permanent.
---
---**Possible errors:**
---* Error and abort the transaction in case of a conflict.
---* Error if the operation fails to write to disk.
---* Error if for some reason memory cannot be allocated.
---
---**Example:**
---
--- ```lua
--- -- Insert test data --
--- box.space.bands:insert { 1, 'Roxette', 1986 }
--- box.space.bands:insert { 2, 'Scorpions', 1965 }
--- box.space.bands:insert { 3, 'Ace of Base', 1987 }
---
--- -- Begin and commit the transaction explicitly --
--- box.begin()
--- box.space.bands:insert { 4, 'The Beatles', 1960 }
--- box.space.bands:replace { 1, 'Pink Floyd', 1965 }
--- box.commit()
---
--- -- Begin the transaction with the specified isolation level --
--- box.begin({ txn_isolation = 'read-committed' })
--- box.space.bands:insert { 5, 'The Rolling Stones', 1962 }
--- box.space.bands:replace { 1, 'The Doors', 1965 }
--- box.commit()
--- ```
function box.commit() end

---End the transaction, but cancel all its data-change operations.
---
---An explicit call to functions outside `box.space` that always yield, such as `fiber.sleep()` or `fiber.yield()`, will have the same effect.
---
---**Example:**
---
--- ```lua
--- -- Insert test data --
--- box.space.bands:insert { 1, 'Roxette', 1986 }
--- box.space.bands:insert { 2, 'Scorpions', 1965 }
--- box.space.bands:insert { 3, 'Ace of Base', 1987 }
---
--- -- Rollback the transaction --
--- box.begin()
--- box.space.bands:insert { 4, 'The Beatles', 1960 }
--- box.space.bands:replace { 1, 'Pink Floyd', 1965 }
--- box.rollback()
--- ```
function box.rollback() end

--TODO: BoxError не хватает корректной обработки

---@class box.savepoint: table

---Return a descriptor of a savepoint, which can be used later by `box.rollback_to_savepoint(savepoint)`.
---
---Savepoints can only be created while a transaction is active, and they are destroyed when a transaction ends
---
---**Possible errors:**
---* Error if for some reason memory cannot be allocated.
---
---**Example:**
---
--- ```lua
--- -- Insert test data --
--- box.space.bands:insert { 1, 'Roxette', 1986 }
--- box.space.bands:insert { 2, 'Scorpions', 1965 }
--- box.space.bands:insert { 3, 'Ace of Base', 1987 }
---
--- -- Rollback the transaction to a savepoint --
--- box.begin()
--- box.space.bands:insert { 4, 'The Beatles', 1960 }
--- save1 = box.savepoint()
--- box.space.bands:replace { 1, 'Pink Floyd', 1965 }
--- box.rollback_to_savepoint(save1)
--- box.commit()
--- ```
---
---@return box.savepoint | box.error savepoint
function box.savepoint() end

---Do not end the transaction, but cancel all its data-change and [`box.savepoint()`](lua://box.savepoint) operations that were done after the specified savepoint.
---
---**Possible errors:**
---* Error if the savepoint does not exist.
---
---**Example:**
---
--- ```lua
--- -- Insert test data --
--- box.space.bands:insert { 1, 'Roxette', 1986 }
--- box.space.bands:insert { 2, 'Scorpions', 1965 }
--- box.space.bands:insert { 3, 'Ace of Base', 1987 }
---
--- -- Rollback the transaction to a savepoint --
--- box.begin()
--- box.space.bands:insert { 4, 'The Beatles', 1960 }
--- save1 = box.savepoint()
--- box.space.bands:replace { 1, 'Pink Floyd', 1965 }
--- box.rollback_to_savepoint(save1)
--- box.commit()
--- ```
---
---@param savepoint box.savepoint
---@return box.error? error
function box.rollback_to_savepoint(savepoint) end

---Execute a function, acting as if the function starts with an implicit [`box.begin()`](lua://box.begin) and ends with an implicit [`box.commit()`](lua://box.commit) if successful, or ends with an implicit [`box.rollback()`](lua://box.rollback) if there is an error.
---
---*Since 2.10.1*
---
---**Possible errors:**
---* Error and abort the transaction in case of a conflict.
---* Error and abort the transaction if the timeout is exceeded.
---* Error if the operation fails to write to disk.
---* Error if for some reason memory cannot be allocated.
---
---**Example:**
---
--- ```lua
--- -- Create an index with the specified sequence --
--- box.schema.sequence.create('id_sequence', { min = 1 })
--- box.space.bands:create_index('primary', { parts = { 'id' }, sequence = 'id_sequence' })
---
--- -- Insert test data --
--- box.space.bands:insert { 1, 'Roxette', 1986 }
--- box.space.bands:insert { 2, 'Scorpions', 1965 }
--- box.space.bands:insert { 3, 'Ace of Base', 1987 }
---
--- -- Define a function --
--- local function insert_band(band_name, year)
---     box.space.bands:insert { nil, band_name, year }
--- end
---
--- -- Begin and commit the transaction implicitly --
--- box.atomic(insert_band, 'The Beatles', 1960)
---
--- -- Begin the transaction with the specified isolation level --
--- box.atomic({ txn_isolation = 'read-committed' },
---         insert_band, 'The Rolling Stones', 1962)
--- ```
---
---@generic T, R
---@param opts { txn_isolation?: box.txn_isolation }
---@param tx_function? fun(...: T...): R...
---@param ... T...
---@return R... retvals The result of the function passed to `atomic()` as an argument.
---@overload fun(tx_function: fun(...: T...): R..., ...: T...): R...
function box.atomic(opts, tx_function, ...) end

---@alias box.on_commit_iterator fun():(number, box.tuple|nil, box.tuple|nil, number) request_id, old_tuple, new_tuple, space_id
---@alias box.on_commit_trigger_func fun(iterator: box.on_commit_iterator?)

---Define a trigger for execution when a transaction ends due to an event such as [`box.commit()`](lua://box.commit).
---
---The trigger function may take an iterator parameter, as described in an example for this section.
---
---The trigger function should not access any database spaces.
---
---If the trigger execution fails and raises an error, the effect is severe and should be avoided -- use Lua's `pcall()` mechanism around code that might fail.
---
---`box.on_commit()` must be invoked within a transaction, and the trigger ceases to exist when the transaction ends.
---
---If the parameters are `(nil, old-trigger-function)`, then the old trigger is deleted.
---
---Details about trigger characteristics are in the [triggers](doc://triggers-box_triggers) section.
---
---**Examples:**
---
--- ```lua
--- -- Insert test data --
--- box.space.bands:insert { 1, 'Roxette', 1986 }
--- box.space.bands:insert { 2, 'Scorpions', 1965 }
--- box.space.bands:insert { 3, 'Ace of Base', 1987 }
---
--- -- Define a function called on commit --
--- function print_commit_result()
---     print('Commit happened')
--- end
---
--- -- Commit the transaction --
--- box.begin()
--- box.space.bands:insert { 4, 'The Beatles', 1960 }
--- box.on_commit(print_commit_result)
--- box.commit()
--- ```
---
---The function parameter can be an iterator.
---
---The iterator goes through the effects of every request that changed a space
---during the transaction.
---
---The iterator has:
---* An ordinal request number.
---* The old value of the tuple before the request (`nil` for an `insert` request).
---* The new value of the tuple after the request (`nil` for a `delete` request).
---* The ID of the space.
---
---The example below displays the effects of two `replace` requests:
---
--- ```lua
--- -- Insert test data --
--- box.space.bands:insert { 1, 'Roxette', 1986 }
--- box.space.bands:insert { 2, 'Scorpions', 1965 }
--- box.space.bands:insert { 3, 'Ace of Base', 1987 }
---
--- -- Define a function called on commit --
--- function print_replace_details(iterator)
---     for request_number, old_tuple, new_tuple, space_id in iterator() do
---         print('request_number: ' .. tostring(request_number))
---         print('old_tuple: ' .. tostring(old_tuple))
---         print('new_tuple: ' .. tostring(new_tuple))
---         print('space_id: ' .. tostring(space_id))
---     end
--- end
---
--- -- Commit the transaction --
--- box.begin()
--- box.space.bands:replace { 1, 'The Beatles', 1960 }
--- box.space.bands:replace { 2, 'The Rolling Stones', 1965 }
--- box.on_commit(print_replace_details)
--- box.commit()
--- ```
---
---The output might look like this:
---
--- ```console
--- request_number: 1
--- old_tuple: [1, 'Roxette', 1986]
--- new_tuple: [1, 'The Beatles', 1960]
--- space_id: 512
--- request_number: 2
--- old_tuple: [2, 'Scorpions', 1965]
--- new_tuple: [2, 'The Rolling Stones', 1965]
--- space_id: 512
--- ```
---
---@param trigger_func box.on_commit_trigger_func
---@param old_trigger_func? box.on_commit_trigger_func
function box.on_commit(trigger_func, old_trigger_func) end

---Define a trigger for execution when a transaction ends due to an event such as [`box.rollback()`](lua://box.rollback).
---
---The parameters and warnings are exactly the same as for [`box.on_commit`](lua://box.on_commit).
---
---@see box.on_commit
---
---@param trigger_func box.on_commit_trigger_func
---@param old_trigger_func? box.on_commit_trigger_func
function box.on_commit(trigger_func, old_trigger_func) end

---@alias box.iterator {
---     iterator: "GE" | "GT" | "LT" | "LE" | "EQ" | "REQ" | "BITS_ALL_NOT_SET" | "BITS_ALL_SET" | "BITS_ANY_SET" | "OVERLAPS" | "NEIGHBOR" | "ALL" | box.index.iterator,
---     after?: string
---}

---@enum box.index.iterator
box.index = {
    EQ = 0,
    REQ = 1,
    ALL = 2,
    LT = 3,
    LE = 4,
    GE = 5,
    GT = 6,
    BITS_ALL_SET = 7,
    BITS_ANY_SET = 8,
    BITS_ALL_NOT_SET = 9,
    OVERLAPS = 10,
    NEIGHBOR = 11,
    NP = 12,
    PP = 13,
}

---Execute a function, provided it has not been executed before.
---
---A passed value is checked to see whether the function has already been executed. If it has been executed before, nothing happens. If it has not been executed before, the function is invoked.
---
---See an example of using `box.once()` [vshard quick start storage code](doc://vshard-quick-start-storage-code).
---
---**Warning:** If an error occurs inside `box.once()` when initializing a database, you can re-execute the failed `box.once()` block without stopping the database. The solution is to delete the `once` object from the system space [`box.space._schema](lua://box.space._schema).
---
---Say `box.space._schema:select{}`, find your `once` object there and delete it.
---
---When `box.once()` is used for initialization, it may be useful to wait until the database is in an appropriate state (read-only or read-write). In that case, see the functions in the [`box.ctl`](lua://box.ctl).
---
---**Note:**
---
---The parameter `key` will be stored in the [`_schema`](lua://box.space._schema) system space after `box.once()` is called in order to prevent a double run.
---
---These keys are global per replica set. So a simultaneous call of `box.once()` with the same key on two instances of the same replica set may succeed on both of them, but it'll lead to a transaction conflict.
---
---**Example:**
---
---The example shows how to re-execute the `box.once()` block that contains the `hello` key.
---
---First, check the `_schema` system space.
---The `_schema` space in the example contains two `box.once` objects -- `oncebye` and `oncehello`:
---
--- ```tarantoolsession
--- app:instance001> box.space._schema:select{}
--- ---
--- - - ['oncebye']
--- - ['oncehello']
--- - ['replicaset_name', 'replicaset001']
--- - ['replicaset_uuid', '72d2d9bf-5d9f-48c4-ba80-9d657e128fee']
--- - ['version', 3, 1, 0]
--- ```
---
---Delete the `oncehello` object:
---
--- ```tarantoolsession
--- app:instance001> box.space._schema:delete('oncehello')
--- ---
--- - ['oncehello']
--- ...
--- ```
---
---After that, check the `_schema` space again:
---
--- ```tarantoolsession
--- app:instance001> box.space._schema:select{}
--- ---
--- - - ['oncebye']
--- - ['replicaset_name', 'replicaset001']
--- - ['replicaset_uuid', '72d2d9bf-5d9f-48c4-ba80-9d657e128fee']
--- - ['version', 3, 1, 0]
--- ...
--- ```
---
---To re-execute the function, call the `box.once()` method again:
---
--- ```tarantoolsession
--- app:instance001> box.once('hello', function() end)
--- ---
--- ...
---
--- app:instance001> box.space._schema:select{}
--- ---
--- - - ['oncebye']
--- - ['oncehello']
--- - ['replicaset_name', 'replicaset001']
--- - ['replicaset_uuid', '72d2d9bf-5d9f-48c4-ba80-9d657e128fee']
--- - ['version', 3, 1, 0]
--- ...
--- ```
---
---@generic T, R
---@param key string a value that will be checked
---@param fnc fun(...: T...): R... function to be executed
---@param ... T... arguments to the function
---@return R...
function box.once(key, fnc, ...) end

---Creates new snapshot of the data and executes checkpoint.gc process
---
---Take a snapshot of all data and store it in [`snapshot.dir`](doc://configuration_reference_snapshot_dir)
---
---To take a snapshot, Tarantool first enters the delayed garbage collection mode for all data. In this mode, the [Tarantool garbage collector](doc://cfg_checkpoint_daemon-garbage-collector) will not remove files which were created before the snapshot started, it will not remove them until the snapshot has finished. To preserve consistency of the primary key, used to iterate over tuples, a copy-on-write technique is employed. If the master process changes part of a primary key, the corresponding process page is split, and the snapshot process obtains an old copy of the page.
---
---In effect, the snapshot process uses multi-version concurrency control in order to avoid copying changes which are superseded while it is running.
---
---Since a snapshot is written sequentially, you can expect a very high write performance (averaging to 80MB/second on modern disks), which means an average database instance gets saved in a matter of minutes.
---
---You may restrict the speed by changing [`snapshot.snap_io_rate_limit`](doc://configuration_reference_snapshot_snap_io_rate_limit).
---
---**Note:**
---
---As long as there are any changes to the parent index memory through concurrent updates, there are going to be page splits, and therefore you need to have some extra free memory to run this command. 10% of [`memtx_memory`](doc://cfg_storage-memtx_memory) is, on average, sufficient.
---
---This statement waits until a snapshot is taken and returns operation result.
---
---**Note:**
---
---**Change notice:** Prior to Tarantool version 1.6.6, the snapshot process caused a fork, which could cause occasional latency spikes. Starting with Tarantool version 1.6.6, the snapshot process creates a consistent read view and this view is written to the snapshot file by a separate thread (the "Write Ahead Log" thread).
---
---Although `box.snapshot()` does not cause a fork, there is a separate fiber which may produce snapshots at regular intervals -- see the discussion of the [checkpoint daemon](doc://configuration_persistence_checkpoint_daemon).
---
--- **Example:**
---
--- ```tarantoolsession
--- tarantool> box.info.version
--- ---
--- - 1.7.0-1216-g73f7154
--- ...
--- tarantool> box.snapshot()
--- ---
--- - ok
--- ...
--- tarantool> box.snapshot()
--- ---
--- - error: can't save snapshot, errno 17 (File exists)
--- ...
--- ```
---
---Taking a snapshot does not cause the server to start a new write-ahead log.
---
---Once a snapshot is taken, old WALs can be deleted as long as all replicated data is up to date. But the WAL which was current at the time `box.snapshot()` started must be kept for recovery, since it still contains log records written after the start of `box.snapshot()`.
---
---An alternative way to save a snapshot is to send a SIGUSR1 signal to the instance.
---
---While this approach could be handy, it is not recommended for use in automation: a signal provides no way to find out whether the snapshot was taken successfully or not.
---
---**Vinyl:**
---
---In vinyl, inserted data is stacked in memory until the limit, set in the [`vinyl_memory`](cfg_storage-vinyl_memory) parameter, is reached. Then vinyl automatically dumps it to the disc. `box.snapshot()` forces this dump in order to have the ability to recover from this checkpoint.
---
---The snapshot files are stored in `{space_id}/{index_id}/*.run`.
---
---Thus, strictly all the data that was written at the time of LSN of the checkpoint is in the `*.run` files on the disk, and all operations that happened after the checkpoint will be written in the `*.xlog`. All dump files created by `box.snapshot()` are consistent and have the same LSN as checkpoint.
---
---At the checkpoint vinyl also rotates the metadata log `*.vylog`, containing data manipulation operations like "create file" and "delete file". It goes through the log, removes duplicating operations from the memory and creates a new `*.vylog` file, giving it the name according to the [vclock](doc://box_introspection-box_info) of the new checkpoint, with "create" operations only. This procedure cleans `*.vylog` and is useful for recovery because the name of the log is the same as the checkpoint signature.
---
---@async
function box.snapshot() end

---@class box.watcher
local watcher = {}

---unregisters the watcher
function watcher:unregister() end

---Update the value of a particular key and notify all key watchers of the update.
---
---*Since 2.10.0*
---
---**Possible errors:**
---
---* The value can't be encoded as MsgPack.
---* The key refers to a ``box.`` system event
---
---**Example:**
---
--- ```
--- -- Broadcast value 42 for the 'foo' key.
--- box.broadcast('foo', 42)
--- ```
---
---@param key string
---@param value any
function box.broadcast(key, value) end

---Subscribe to events broadcast by a local host.
---
---*Since 2.10.0*
---
---To read more about watchers, see the [Functions for watchers](doc://box-watchers) section.
---
---**Note:**
---
---Keep in mind that garbage collection of a watcher handle doesn't lead to the watcher's destruction. In this case, the watcher remains registered.
---
---It is okay to discard the result of `watch` function if the watcher will never be unregistered.
---
---**Example:**
---
--- ```lua
--- -- Broadcast value 42 for the 'foo' key.
--- box.broadcast('foo', 42)
---
--- local log = require('log')
--- -- Subscribe to updates of the 'foo' key.
--- local w = box.watch('foo', function(key, value)
---     assert(key == 'foo')
---     log.info("The box.id value is '%d'", value)
--- end)
--- ```
---
---If you don't need the watcher anymore, you can unregister it using the command below:
---
--- ```lua
--- w:unregister()
--- ```
---
---@param key string
---@param func fun(key: string, value: any)
---@return box.watcher
function box.watch(key, func) end

---Subscribe once to events broadcast by a local host.
---
---*Since 2.10.0*
---
---Returns the current value of a given notification key.
---
---The function can be used as an alternative to [`box.watch()`](lua://box-watch) when the caller only needs the current value without subscribing to future changes.
---
---To read more about watchers, see the [box.watchers](lua://box.watchers) section.
---
---**Example:**
---
--- ```lua
---
--- -- Broadcast value 42 for the 'foo' key.
--- box.broadcast('foo', 42)
---
--- -- Get the value of this key
--- tarantool> box.watch_once('foo')
--- ---
--- - 42
--- ...
---
--- -- Non-existent keys' values are empty
--- tarantool> box.watch_once('none')
--- ---
--- ...
--- ```
---
---@param key string
---@param func fun(key: string, value: any)
---@return box.watcher
function box.watch_once(key, func) end

---@alias box.update_operation
---| '+' # Addition. Values must be numeric, e.g. unsigned or decimal.
---| '-' # Subtraction. Values must be numeric.
---| '&' # Bitwise AND. Values must be unsigned numeric.
---| '|' # Bitwise OR. Values must be unsigned numeric.
---| '^' # Bitwise XOR. Values must be unsigned numeric.
---| ':' # String splice.
---| '!' # Insertion of a new field.
---| '#' # Deletion.
---| '=' # Assignment.
