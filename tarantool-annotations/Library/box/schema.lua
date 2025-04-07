---@meta

---# Builtin `box.schema` submodule
---
---The `box.schema` submodule has data-definition functions for spaces, users, roles, function tuples, and sequences.
box.schema = {}

box.schema.space = {}

---@class box.schema.create_space_options: table
---@field engine? "memtx" | "vinyl" (Default: "memtx") `memtx` keeps all data in random-access memory (RAM), and therefore has a low read latency.
---@field field_count? number fixed count of fields: for example if field_count=5, it is illegal to insert a tuple with fewer than or more than 5 fields
---@field format? box.space.format
---@field id? number (Default: last space's id, +1) unique identifier: users can refer to spaces with the id instead of the name
---@field if_not_exists? boolean (Default: false) create space only if a space with the same name does not exist already, otherwise do nothing but do not cause an error
---@field is_local? boolean (Default: false) space contents are replication-local: changes are stored in the write-ahead log of the local node but there is no replication.
---@field is_sync? boolean (Default: false) any transaction doing a DML request on this space becomes synchronous
---@field temporary? boolean (Default: false) space contents are temporary: changes are not stored in the write-ahead log and there is no replication. Note regarding storage engine: vinyl does not support temporary spaces.
---@field user? string (Default: current user's name) name of the user who is considered to be the space's owner for authorization purposes

---Create a [space](lua://box.space).
---
---You can use either syntax. For example, `s = box.schema.space.create('tester')` has the same effect as `s = box.schema.create_space('tester')`.
---
---There are [three syntax variations](doc://app_server-object_reference) for object references targeting space objects, for example `box.schema.space.drop({space-id})` drops a space.
---
---However, the common approach is to use functions attached to the space objects, for example [`space_object:drop()`](lua://box.space.drop).
---
---After a space is created, usually the next step is to [create an index](lua://box.space.create_index) for it, and then it is available for insert, select, and all the other [`box.space`](box_space) functions.
---
---@see box.schema.create_space
---
---@generic T, U
---@param space_name string
---@param options? box.schema.create_space_options
---@return box.space<T, U>
function box.schema.space.create(space_name, options) end

---Create a [space](lua://box.space).
---
---You can use either syntax. For example, `s = box.schema.space.create('tester')` has the same effect as `s = box.schema.create_space('tester')`.
---
---There are [three syntax variations](doc://app_server-object_reference) for object references targeting space objects, for example `box.schema.space.drop({space-id})` drops a space.
---
---However, the common approach is to use functions attached to the space objects, for example [`space_object:drop()`](lua://box.space.drop).
---
---After a space is created, usually the next step is to [create an index](lua://box.space.create_index) for it, and then it is available for insert, select, and all the other [`box.space`](box_space) functions.
---
---@see box.schema.space.create
---
---@generic T, U
---@param space_name string
---@param options? box.schema.create_space_options
---@return box.space<T, U>
function box.schema.create_space(space_name, options) end

---Upgrade the schema to the current version.
---
---If you created a database with an older Tarantool version and have now installed a newer version, make the request `box.schema.upgrade()`. This updates
---
---Tarantool system spaces to match the currently installed version of Tarantool. You can learn about the general upgrade process from the [upgrades](doc://admin-upgrades) topic.
---
---**Example:** here is what happens when you run `box.schema.upgrade()` with a database created with Tarantool version 1.6.4 to version 1.7.2 (only a small part of the output is shown):
---
--- ```tarantoolsession
--- tarantool> box.schema.upgrade()
--- alter index primary on _space set options to {"unique":true}, parts to [[0,"unsigned"]]
--- alter space _schema set options to {}
--- create view _vindex...
--- grant read access to 'public' role for _vindex view
--- set schema version to 1.7.0
--- ---
--- ...
--- ```
---
---You can also put the request `box.schema.upgrade()` inside a [`box.once()`](doc://box.once) function in your Tarantool [initialization file](doc://index-init_label).
---
---On startup, this will create new system spaces, update data type names (for example, `num` -> `unsigned`, `str` -> `string`) and options in Tarantool system spaces.
---
---@see box.schema.downgrade
function box.schema.upgrade() end

---Downgrade the schema to the specified version.
---
---Allows you to downgrade a database to the specified Tarantool version.
---
---This might be useful if you need to run a database on older Tarantool versions.
---
---To prepare a database for using it on an older Tarantool instance, call `box.schema.downgrade` and pass the desired Tarantool version:
---
--- ```tarantoolsession
--- tarantool> box.schema.downgrade('2.8.4')
--- ```
---
---**Note:**
---
---The Tarantool's downgrade procedure is similar to the upgrade process that is described in the [upgrades](doc://admin-upgrades) topic.
---
---You need to run `box.schema.downgrade()` only on master and execute `box.snapshot()` on every instance in a replica set before restart to an older version.
---
---To see Tarantool versions available for downgrade, call [`box.schema.downgrade_versions()`](lua://<box.schema.downgrade_versions). The oldest release available for downgrade is `2.8.2`.
---
---Note that the downgrade process might fail if the database enables specific features not supported in the target Tarantool version.
---
---You can see all such issues using the [`box.schema.downgrade_issues()`](lua://box.schema.downgrade_issues) method, which accepts the target version.
---
---**Example:** `downgrade` to the `2.8.4` version fails if you use [tuple compression](doc://tuple_compression) or field [constraints](doc://constraint_functions) in your database:
---
--- ```tarantoolsession
--- tarantool> box.schema.downgrade_issues('2.8.4')
--- ---
--- - - Tuple compression is found in space 'bands', field 'band_name'. It is supported
--- starting from version 2.10.0.
--- - Field constraint is found in space 'bands', field 'year'. It is supported starting
--- from version 2.10.0.
--- ...
--- ```
---
---@see box.schema.upgrade
---
---@param version string
function box.schema.downgrade(version) end

---Return a list of Tarantool versions available for downgrade.
---
---To learn how to downgrade a database to the specified Tarantool version, see [`box.schema.downgrade()`](lua://box.schema.downgrade).
---
---@see box.schema.downgrade
function box.schmea.downgrade_versions() end

---Return a list of downgrade issues for the specified Tarantool version.
---
---To learn how to downgrade a database to the specified Tarantool version, see [`box.schema.downgrade()`](lua://box.schema.downgrade).
---
---@param version string
function box.schmea.downgrade_issues(version) end

---User privileges management.
---
---This module hasn't been documented yet.
---
---@type any
box.schema.user = {}

---Role privileges management.
---
---This module hasn't been documented yet.
---
---@type any
box.schema.role = {}

---Stored function management.
---
---This module hasn't been documented yet.
---
---@type any
box.schema.func = {}

---@alias box.schema.user.grant_object_type
---| "space"
---| "function"
---| "sequence"
---| "role"
