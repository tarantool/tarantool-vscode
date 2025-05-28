---@meta

---# Builtin `box.iproto` submodule
---
---*Since 2.11.0*
---
---The `box.iproto` submodule provides the ability to work with the network subsystem of Tarantool.
---It allows you to extend the [`IPROTO`](doc://box_protocol) functionality from Lua.
---
---With this submodule, you can:
---
---* [Parse unknown IPROTO request types](doc://reference_lua-box_iproto_override)
---* [Send arbitrary IPROTO packets](doc://reference_lua-box_iproto_send)
---* [Override the behavior](doc://reference_lua-box_iproto_override) of the existing and unknown request types in the binary protocol
---
---The submodule exports all IPROTO [constants](doc://internals-box_protocol) and [doc://features](internals-iproto-keys-features) to Lua.
box.iproto = {}

---Send an IPROTO packet over the session's socket with the given MsgPack header and body.
---
---*Since 2.11.0*.
---
---The header and body contain exported IPROTO constants from the [box.iproto()](doc://box_iproto) submodule.
---
---Possible IPROTO constant formats:
---
---* A constant from the corresponding [box.iproto](doc://box_iproto) subnamespace (`box.iproto.SCHEMA_VERSION`, `box.iproto.REQUEST_TYPE`)
---
---Send an [IPROTO](internals-iproto-format) packet over the session\'s socket with the given MsgPack header and body. The header and body contain exported IPROTO constants from the [box.iproto()](box_iproto) submodule. Possible IPROTO constant formats:
---
---**Possible errors:**
---
---* `ER_SESSION_CLOSED` -- the session is closed.
---* `ER_NO_SUCH_SESSION` -- the session does not exist.
---* `ER_MEMORY_ISSUE` -- out-of-memory limit has been reached.
---* `ER_WRONG_SESSION_TYPE` -- the session type is not binary.
---
---The function works for binary sessions only. For details, see [box.session.type()](doc://box_session-type).
---
---For details, see `src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`__.
---
---**Examples:**
---
---Send a packet using Lua tables and string IPROTO constants as keys:
---
--- ```lua
--- box.iproto.send(box.session.id(),
---         { request_type = box.iproto.type.OK,
---           sync = 10,
---           schema_version = box.info.schema_version },
---         { data = 1 })
--- ```
---
---Send a packet using Lua tables and numeric IPROTO constants:
---
--- ```lua
--- box.iproto.send(box.session.id(),
---         { [box.iproto.key.REQUEST_TYPE] = box.iproto.type.OK,
---           [box.iproto.key.SYNC] = 10,
---           [box.iproto.key.SCHEMA_VERSION] = box.info.schema_version },
---         { [box.iproto.key.DATA] = 1 })
--- ```
---
---Send a packet that contains only the header:
---
--- ```lua
--- box.iproto.send(box.session.id(),
---         { request_type = box.iproto.type.OK,
---           sync = 10,
---           schema_version = box.info.schema_version })
--- ```
---
---@param sid number the IPROTO session identifier (see [box.session.id()](doc://box_session-id))
---@param header table | string ader: a request header encoded as MsgPack
---@param body? table | string a request body encoded as MsgPack
---@return integer 0 on success, otherwise an error is raised
function box.iproto.send(sid, header, body) end

---Contains the keys from the IPROTO_BALLOT requests.
---
---Learn more: [IPROTO_BALLOT keys](doc://internals-iproto-keys-ballot).
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.ballot_key.IS_RO_CFG
--- ---
--- - 1
--- ...
--- tarantool> box.iproto.ballot_key.VCLOCK
--- ---
--- - 2
--- ...
--- ```
---
---@enum box.iproto.ballot_key
box.iproto.ballot_key = {
    CAN_LEAD = 7,
    INSTANCE_NAME = 10,
    IS_ANON = 5,
    IS_BOOTED = 6,
    IS_RO = 4,
    IS_RO_CFG = 1,
    REGISTERED_REPLICA_UUIDS = 9,
    BOOTSTRAP_LEADER_UUID = 8,
    VCLOCK = 2,
    GC_VCLOCK = 3,
}

---@alias box.iproto.feature
---| 'transactions'
---| 'watchers'
---| 'error_extension'
---| 'call_arg_tuple_extension'
---| 'pagination'
---| 'is_sync'
---| 'space_and_index_names'
---| 'insert_arrow'
---| 'streams'
---| 'watch_once'
---| 'call_ret_tuple_extension'
---| 'fetch_snapshot_cursor'
---| 'dml_tuple_extension'
---| string

---Contains the IPROTO protocol features that are supported by the server.
---
---Each feature is mapped to its corresponding code.
---
---Learn more: [IPROTO_FEATURES](doc://internals-iproto-keys-features).
---
---The features in the namespace are written:
---
---* In lowercase letters
---* Without the `IPROTO_FEATURE_` prefix
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.feature.streams
--- ---
--- - 0
--- ...
--- tarantool> box.iproto.feature.transactions
--- ---
--- - 1
--- ...
--- ```
---
---@type table<box.iproto.feature, integer>
box.iproto.feature = {}

---Contains the flags from the `IPROTO_FLAGS` key.
---
---Learn more: [IPROTO_FLAGS key](doc://box_protocol-flags).
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.flag.COMMIT
--- ---
--- - 1
--- ...
--- tarantool> box.iproto.flag.WAIT_SYNC
--- ---
--- - 2
--- ...
--- ```
---
---@enum box.iproto.flag
box.iproto.flag = {
    WAIT_SYNC = 2,
    COMMIT = 1,
    WAIT_ACK = 4,
}

---Contains all available request keys, except raft, metadata, and ballot keys.
---
---Learn more: [Keys used in requests and responses](doc://internals-iproto-keys).
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.key.SYNC
--- ---
--- - 1
--- ...
--- ```
---
---@enum box.iproto.key
box.iproto.key = {
    SCHEMA_VERSION = 5,
    ERROR_24 = 49,
    STREAM_ID = 10,
    STMT_ID = 67,
    BALLOT = 41,
    IS_SYNC = 97,
    AUTH_TYPE = 91,
    TUPLE_META = 42,
    SYNC = 1,
    VERSION = 84,
    GROUP_ID = 7,
    VCLOCK = 38,
    FLAGS = 9,
    SQL_BIND = 65,
    EVENT_DATA = 88,
    SPACE_ID = 16,
    TERM = 83,
    EXPR = 39,
    ID_FILTER = 81,
    METADATA = 50,
    INDEX_NAME = 95,
    KEY = 32,
    OPTIONS = 43,
    TIMESTAMP = 4,
    DATA = 48,
    VCLOCK_SYNC = 90,
    INSTANCE_NAME = 93,
    ARROW = 54,
    USER_NAME = 35,
    INSTANCE_UUID = 36,
    SERVER_VERSION = 6,
    NEW_TUPLE = 45,
    BIND_METADATA = 51,
    TUPLE_FORMATS = 96,
    CHECKPOINT_LSN = 100,
    INDEX_BASE = 21,
    FEATURES = 85,
    REPLICA_ID = 2,
    EVENT_KEY = 87,
    IS_CHECKPOINT_JOIN = 98,
    REQUEST_TYPE = 0,
    LIMIT = 18,
    OPS = 40,
    TXN_ISOLATION = 89,
    INDEX_ID = 17,
    SQL_INFO = 66,
    AFTER_POSITION = 46,
    AFTER_TUPLE = 47,
    TUPLE = 33,
    TIMEOUT = 86,
    FUNCTION_NAME = 34,
    REPLICA_ANON = 80,
    CHECKPOINT_VCLOCK = 99,
    OFFSET = 19,
    OLD_TUPLE = 44,
    LSN = 3,
    TSN = 8,
    ITERATOR = 20,
    FETCH_POSITION = 31,
    BIND_COUNT = 52,
    POSITION = 53,
    SQL_TEXT = 64,
    ERROR = 82,
    REPLICASET_NAME = 92,
    SPACE_NAME = 94,
    REPLICASET_UUID = 37,
}

---Contains the `IPROTO_FIELD_*` keys, which are nested in the IPROTO_METADATA key.
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.metadata_key.NAME
--- ---
--- - 0
--- ...
--- tarantool> box.iproto.metadata_key.TYPE
--- ---
--- - 1
--- ...
--- ```
---
---@enum box.iproto.metadata_key
box.iproto.metadata_key = {
    COLL = 2,
    SPAN = 5,
    IS_AUTOINCREMENT = 4,
    TYPE = 1,
    NAME = 0,
    IS_NULLABLE = 3,
}

---Set a new IPROTO request handler callback for the given request type.
---
---*Since 2.11.0*.
---
---**Possible errors:**
---
---If a Lua handler throws an exception:
---* `ER_PROC_LUA` -- an exception is thrown from a Lua handler, diagnostic is not set
---* Other diagnostics from `src/box/errcode.h` -- when diagnostic is set
---
---**Warning:**
---
---When using `box.iproto.override()`, it is important that you follow the wire protocol. The server response should match the return value types of the corresponding request type. Otherwise, it could lead to peer breakdown or undefined behavior.
---
---**Example:**
---
--- ```lua
--- local function iproto_select_handler_lua(header, body)
---     if body.space_id == 512 then
---         box.iproto.send(box.session.id(),
---                 { request_type = box.iproto.type.OK,
---                   sync = header.SYNC,
---                   schema_version = box.info.schema_version },
---                 { data = { 1, 2, 3 } })
---         return true
---     end
---     return false
--- end
--- 
--- box.iproto.override(box.iproto.type.SELECT, iproto_select_handler_lua)
--- box.iproto.override(box.iproto.type.SELECT, nil) -- Reset handler
--- box.iproto.override(box.iproto.type.UNKNOWN, iproto_unknown_request_handler_lua)
--- ```
---
---@param request_type box.iproto.type
---@param handler? fun(sid, header: userdata, body: userdata): bool request handler that returns `true` on success, otherwise `false`. On `false`, there is a fallback
function box.iproto.override(request_type, handler) end

---The set of IPROTO protocol features supported by the server.
---
---Learn more: [net.box features](doc://net_box-connect).
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.protocol_features
--- ---
--- - transactions: true
---   watchers: true
---   error_extension: true
---   streams: true
---   pagination: true
--- ...
--- ```
---
---@type table<box.iproto.feature, boolean>
box.iproto.protocol_features = {}

---The current IPROTO protocol version of the server.
---
---Learn more: [IPROTO_ID](doc://box_protocol-id).
---
--- **Example:**
--- 
--- ```lua
--- tarantool> box.iproto.protocol_version
--- ---
--- - 4
--- ...
--- ```
---
---@type integer
box.iproto.protocol_version = nil

---Contains the keys from the `IPROTO_RAFT_*` requests.
---
---Learn more: [Synchronous replication keys](doc://internals-iproto-keys-synchro-replication).
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.raft_key.TERM
--- ---
--- - 0
--- ...
--- tarantool> box.iproto.raft_key.VOTE
--- ---
--- - 1
--- ...
--- ```
---
---@enum box.iproto.raft_key
box.iproto.raft_key = {
    STATE = 2,
    LEADER_ID = 4,
    VOTE = 1,
    TERM = 0,
    VCLOCK = 3,
    IS_LEADER_SEEN = 5,
}

---Contains all available request types.
---
---Learn more: [Client-server requests and responses](doc://internals-requests_responses).
---
---**Example:**
---
--- ```lua
--- tarantool> box.iproto.type.UNKNOWN
--- ---
--- - -1
--- ...
--- tarantool> box.iproto.type.CHUNK
--- ---
--- - 128
--- ...
--- ```
---
---@enum box.iproto.type
box.iproto.type = {
    NOP = 12,
    INSERT = 2,
    EXECUTE = 11,
    PREPARE = 13,
    VOTE = 68,
    RAFT_PROMOTE = 31,
    UPDATE = 4,
    RAFT_DEMOTE = 32,
    SELECT = 1,
    VOTE_DEPRECATED = 67,
    EVENT = 76,
    PING = 64,
    FETCH_SNAPSHOT = 69,
    RAFT_ROLLBACK = 41,
    WATCH = 74,
    INSERT_ARROW = 17,
    BEGIN = 14,
    ROLLBACK = 16,
    REGISTER = 70,
    JOIN_SNAPSHOT = 72,
    UNKNOWN = -1,
    JOIN_META = 71,
    SUBSCRIBE = 66,
    CHUNK = 128,
    DELETE = 5,
    COMMIT = 15,
    WATCH_ONCE = 77,
    ID = 73,
    UNWATCH = 75,
    EVAL = 8,
    JOIN = 65,
    OK = 0,
    CALL = 10,
    RAFT_CONFIRM = 40,
    CALL_16 = 6,
    REPLACE = 3,
    RAFT = 30,
    TYPE_ERROR = 32768,
    AUTH = 7,
    UPSERT = 9,
}
