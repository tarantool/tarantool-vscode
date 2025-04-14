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
function box.schema.downgrade_versions() end

---Return a list of downgrade issues for the specified Tarantool version.
---
---To learn how to downgrade a database to the specified Tarantool version, see [`box.schema.downgrade()`](lua://box.schema.downgrade).
---
---@param version string
function box.schema.downgrade_issues(version) end

---User privileges management.
box.schema.user = {}

---Create a user.
---
---**Note:** The maximum number of users is 32.
---
---**Examples:**
---
--- ```lua
--- box.schema.user.create('testuser')
--- ```
---
---@param username string
---@param options? { if_not_exists?: boolean, password?: string }
function box.schema.user.create(username, options) end

---Drop a user.
---
---**Examples:**
---
--- ```lua
--- box.schema.user.drop('testuser')
--- ```
---
---@param username string
---@param options? { if_exists?: boolean }
function box.schema.user.drop(username, options) end

---@alias box.schema.privileges.permissions
---| 'read' # Allows reading data of the specified object. For example, this permission can be used to allow a user to select data from the specified space.
---| 'write' # Allows updating data of the specified object. For example, this permission can be used to allow a user to modify data in the specified space.
---| 'create' # Allows creating objects of the specified type. For example, this permission can be used to allow a user to create new spaces. Note this permission requires read and write access to certain system spaces.
---| 'alter' # Allows altering objects of the specified type. Note this permission requires read and write access to certain system spaces.
---| 'drop' # Allows dropping objects of the specified type. Note this permission requires read and write access to certain system spaces.
---| 'execute' # For role, allows using the specified role. For other object types, allows calling a function.
---| 'session' # Allows a user to connect to an instance over IPROTO.
---| 'usage' # Allows a user to use their privileges on database objects (for example, read, write, and alter spaces).
---| string # Multiple permissions split by ','. For example, `read,write` means that the user can read and write data from the specified object.

---@alias box.schema.privileges.object_type
---| 'universe' # A database (box.schema) that contains database objects, including spaces, indexes, users, roles, sequences, and functions. Granting privileges to universe gives a user access to any object in the database.
---| 'user' # A user.
---| 'role' # A role.
---| 'space' # A space.
---| 'function' # A function.
---| 'sequence' # A sequence.
---| 'lua_eval' # Executing arbitrary Lua code.
---| 'lua_call' # Calling any global user-defined Lua function.
---| 'sql' # Executing an arbitrary SQL statement.

---Grant privileges a user or to another role.
---
---If `'function','{object-name}'` is specified, then a _func tuple with that object-name must exist.
---
---**Variation:** instead of `object-type, object-name` say `universe` which means 'all object-types and all objects'. In this case, object name is omitted.
---
---**Variation:** instead of `permissions, object-type, object-name` say `role-name`.
---
---**Variation:** instead of `box.schema.user.grant('{username}','usage,session','universe',nil, {if_not_exists=true})` say `box.schema.user.enable('{username}')`.
---
---**Examples:**
---
--- ```lua
--- box.schema.user.grant('testuser', 'read', 'space', 'writers')
--- box.schema.user.grant('testuser', 'read,write', 'space', 'books')
--- ```
---
---@param username string The name of a user to grant privileges to
---@param permissions box.schema.privileges.permissions One or more permissions to grant to the user (for example, `read` or `read,write`)
---@param object_type box.schema.privileges.object_type A database object type to grant privileges to (for example, `space`, `role`, or `function`)
---@param object_name string The name of a database object to grant privileges to
---@param options? { grantor?: string | number, if_not_exists?: boolean }
---@overload fun(username: string, permissions: box.schema.privileges.permissions, universe: 'universe', _: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
---@overload fun(username: string, role_name: string, _1: nil, _2: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
function box.schema.user.grant(username, permissions, object_type, object_name, options) end

---Revoke privileges from a user or from another role.
---
---If `'function','{object-name}'` is specified, then a _func tuple with that object-name must exist.
---
---**Variation:** instead of `object-type, object-name` say 'universe' which means 'all object-types and all objects'.
---
---**Variation:** instead of `permissions, object-type, object-name` say `role-name`.
---
---**Variation:** instead of `box.schema.user.revoke('{username}','usage,session','universe',nil,` :code:`{if_exists=true})` say `box.schema.user.disable('{username}')`.
---
---**Examples:**
---
--- ```lua
--- box.schema.user.revoke('testuser', 'write', 'space', 'books')
--- ```
---
---@param username string The name of a user to grant privileges to
---@param permissions box.schema.privileges.permissions One or more permissions to grant to the user (for example, `read` or `read,write`)
---@param object_type box.schema.privileges.object_type A database object type to grant privileges to (for example, `space`, `role`, or `function`)
---@param object_name string The name of a database object to grant privileges to
---@param options? { grantor?: string | number, if_not_exists?: boolean }
---@overload fun(username: string, permissions: box.schema.privileges.permissions, universe: 'universe', _: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
---@overload fun(username: string, role_name: string, _1: nil, _2: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
function box.schema.user.revoke(username, object_type, object_name, options) end

---Sets a password for a currently logged in or a specified user.
---
---* A currently logged-in user can change their password using `box.schema.user.passwd(password)`.
---* An administrator can change the password of another user with `box.schema.user.passwd(username, password)`.
---
---**Examples:**
---
--- Set a password for the current user:
--- ```lua
--- box.schema.user.passwd('foobar')
--- ```
---
--- Set a password for the specified user:
--- ```lua
--- box.schema.user.passwd('testuser', 'foobar')
--- ```
---
---@param username string A username
---@param password string A new password
---@overload fun(password: string)
function box.schema.user.passwd(username, password) end

---Return a hash of a user's password.
---
---For explanation of how Tarantool maintains passwords, see section [Passwords](doc://authentication-passwords) and reference on [box.space._user](lua://box.space.user) space.
---
---**Note:**
---
---* If a non-'guest' user has no password, it’s **impossible** to connect to Tarantool using this user. The user is regarded as "internal" only, not usable from a remote connection.
---
---Such users can be useful if they have defined some procedures with the [`SETUID`](lua://box.schema.func.create) option, on which privileges are granted to externally-connectable users.
---
---This way, external users cannot create/drop objects, they can only invoke procedures.
---
---* For the 'guest' user, it’s impossible to set a password: that would be misleading, since 'guest' is the default user on a newly-established connection over a [binary port](doc://admin-security), and Tarantool does not require a password to establish a [binary connection](doc://box_protocol-iproto_protocol).
---
---It is, however, possible to change the current user to ‘guest’ by providing the [AUTH packet](doc://box_protocol-authentication) with no password at all or an empty password. This feature is useful for connection pools, which want to reuse a connection for a different user without re-establishing it.
---
---**Example:**
---
--- ```lua
--- box.schema.user.password('foobar')
--- ```
---
---@param password string Password to be hashed
---@return string
function box.schema.user.password(password) end

---@alias box.schema.privileges [box.schema.privileges.permissions, box.schema.privileges.object_type, string | nil][]

---Return a description of a user's privileges.
---
---See [privileges](doc://authentication-owners_privileges) for more information on user's privileges.
---
---@param username? string Username. If not supplied, the current user who is logged in is used.
---@return box.schema.privileges
function box.schema.user.info(username) end

---Check if user exists.
---
---For explanation of how Tarantool maintains user data, see section [Users](doc://authentication-users) and reference on [box.space._user](lua://box.space.user) space.
---
---@param username? string The name of the user
---@return bool exists `true` if a user exists; `false` if a user does not
function box.schema.user.exists(username) end

---Role privileges management.
box.schema.role = {}

function box.schema.role.create(role_name, options) end

function box.schema.role.drop(role_name, options) end

---Grant privileges a role.
---
---If `'function','{object-name}'` is specified, then a _func tuple with that object-name must exist.
---
---**Variation:** instead of `object-type, object-name` say `universe` which means 'all object-types and all objects'. In this case, object name is omitted.
---
---**Variation:** instead of `permissions, object-type, object-name` say `role-name`.
---
---**Examples:**
---
--- ```lua
--- box.schema.role.grant('writers_space_reader', 'read', 'space', 'writers')
--- box.schema.role.grant('books_space_manager', 'read,write', 'space', 'books')
--- ```
---
---@param role_name string The name of a role to grant privileges to
---@param permissions box.schema.privileges.permissions One or more permissions to grant to the role (for example, `read` or `read,write`)
---@param object_type box.schema.privileges.object_type A database object type to grant privileges to (for example, `space`, `role`, or `function`)
---@param object_name string The name of a database object to grant privileges to
---@param options? { grantor?: string | number, if_not_exists?: boolean }
---@overload fun(role_name: string, permissions: box.schema.privileges.permissions, universe: 'universe', _: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
---@overload fun(role_name: string, role_name: string, _1: nil, _2: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
function box.schema.role.grant(role_name, object_type, object_name, options) end

---Revoke privileges from a role.
---
---If `'function','{object-name}'` is specified, then a _func tuple with that object-name must exist.
---
---**Variation:** instead of `object-type, object-name` say 'universe' which means 'all object-types and all objects'.
---
---**Variation:** instead of `permissions, object-type, object-name` say `role-name`.
---
---@param role_name string The name of a role to grant privileges to
---@param permissions box.schema.privileges.permissions One or more permissions to grant to the role (for example, `read` or `read,write`)
---@param object_type box.schema.privileges.object_type A database object type to grant privileges to (for example, `space`, `role`, or `function`)
---@param object_name string The name of a database object to grant privileges to
---@param options? { grantor?: string | number, if_not_exists?: boolean }
---@overload fun(role_name: string, permissions: box.schema.privileges.permissions, universe: 'universe', _: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
---@overload fun(role_name: string, role_name: string, _1: nil, _2: nil, options?: { grantor?: string | number, if_not_exists?: boolean }})
function box.schema.role.revoke(role_name, object_type, object_name, options) end

---Return a description of a role's privileges.
---
---See [privileges](doc://authentication-owners_privileges) for more information on role's privileges.
---
---@param role_name string
---@return box.schema.privileges
function box.schema.role.info(role_name) end

---Check if role exists.
---
---@param role_name string
---@return bool exists `true` if a role exists; `false` if a role does not
function box.schema.role.exists(role_name) end

---Stored function management.
---
---This module hasn't been documented yet.
---
---@type any
box.schema.func = {}
