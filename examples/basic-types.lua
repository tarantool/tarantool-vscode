-- This file guides how to write your own type annotations for custom Tarantool
-- Lua code.

-- Lua Language server offers you a variety of a builtin types: specific
-- literals, `nil`, `number`, `integer`, `string`, `boolean`. There are also
-- `any`, `unknown` types that don't represent a specific type.

-- There are a few compound builtin types. Assume capital letters to be some
-- types.
-- * A type union `T1 | T2 | ... | Tn` means one of the type.
-- * Arrays defined as `T[]` where `T` is another type.
-- * Tables might be defined using `table<K, V>`, `{ [K]: V }`, or
--   `{ n1: V1, n2: V2, ... }`.
-- * Tuples might be defined using [T1, T2, T3, ...].
-- * Functions use the `fun(arg1: T1, arg2: T2, ...): R1, R2, ...` syntax.

-- You might document and annotate your code using triple-dash (`---`) comments.
-- You might provide types for variables using `@type`. Every Lua definition
-- also allows you to provide a Markdown documentation on the object.

---@type integer
local a = 5

---@type 5
local a_const = 5

---@type 1 | 2 | 3 | 4 | 5
local a_union_const = 5

---@type fun(x: any): string
local conv_string = tostring

---@type { name: string, age: integer, job?: string }
local user = { name = 'John', age = 15 }

---# Important `a` variable.
---
---It's an *important* version of `a` variable providing Markdown documentation
---on it.
---
---@type integer
local a_important = 5

---@type number
local wrong_type = 'not a number' -- Warning: type mismatch!

-- Functions are annotated using `@param` and `@return` annotations.

---Sum two numbers.
---
---@param a number The first number.
---@param b number The second number.
---@return number The sum of `a` and `b`.
local function sum(a, b) return a + b end

---Divide two numbers.
---
---May return `nil` and message string on error.
---
---@param a number The first number.
---@param b number The second number.
---@return number? res Optional result.
---@return string? error Optional error message.
local function div_may_fail(a, b) return 0 end

---Find the logarithm of the number.
---
---@param a number The number.
---@param base? number Optional base. Defaults to 2.
---@return number Logarithm of the `a`.
local function log(a, base) return 0 end

-- Sometimes it's not necessary if the type might be inferred based on the
-- consts and on the provided type definitions. Note that LSP tries to tighten
-- the type to the most precise one.

local b = {'john', 15} -- Inferred as `['john', 15]`.
local a_str = tostring(a) -- Inferred as a `string`.

-- `@alias` annotation allows you to create type-level aliases.

---@alias user_tuple [string, number]

---@type user_tuple
local b_new = b
local b_name = b[1] -- Inferred as `string`.
local b_age = b[2] -- Inferred as `number`.

-- Aliases might be mutiline. E.g. they can be used for enumerations.

---@alias crud_operation
---| 'create' # Create an element. Note that `#` is required for a comment.
---| 'read' # Read an element.
---| 'update' # Update an element.
---| 'delete' # Delete an element.

---@type crud_operation
local crud_op = 'create'
---@type crud_operation
local crud_op_with_typo = 'creat' -- Warning!

-- In Lua metatables are commonly used to implement classes. Thus, LSP provides
-- `@class` annotation for describing them.

---User account class.
---
---@class account
---@field id integer This is a description. It's just an account id.
---@field private _amount integer Amount of money the account have. Private.
---@field name string Real user's name.
---@field active? boolean This is an optional `active` boolean flag.
local account_mt = {}

---Account class constructor.
---
---@param name string Account's name
---@return account new_account Created account.
local function create_account(name)
    return setmetatable({
        id = 0, -- TODO: change id to a real one.
        _amount = 0,
        name = name,
        -- Note that `active` might not be provided while the other fields are
        -- required.
    }, account_mt)
end

-- Class methods are defined using the `:` or `.` syntax.

---Perform a deposit by a user.
---
---@param amount integer Amount to deposit.
---@return integer new_amount New account's amount.
function account_mt:deposit(amount)
    self._amount = self._amount + amount
    return self._amount
end

---@type account
local guest = create_account('guest')

-- Notice that LSP now assists you with the defined methods and return types.

local initial_guest_amount = guest:deposit(1000) -- Inferred as `integer`.

-- Classes might be derived one from another inheriting the methods and the
-- fields.

---@class admin_account: account
---@field corp_mail? string
local admin_account_mt = {}

local admin = ({} --[[@as admin_account]])

local init_admin_amount = admin:deposit(99999999999) -- Inferred as `integer`.
admin.corp_mail = 'admin@site.com'

-- Classes might be generic. These generics can be used within the methods
-- too.

---A collection of unique elements.
---
---@class set<T>
---@field private _elements T[]
local set_mt = {}

---@generic T
---@param elements T[]
---@return set<T>
local function create_set(elements) end

---Insert an element into the set.
---
---Doesn't affect the original set.
---
---@param el T An inserted element.
---@return set<T> new_set A new set.
function set_mt:insert(el) end

---Choice a random element from the set.
---
---@return T random_element Random element of the set.
function set_mt:choice() end

local num_set = create_set({1, 2}) -- Inferred as `set<1 | 2>`
local extended_num_set = num_set:insert(15) -- Inferred as `set<1 | 2>`
local random_num = num_set:choice() -- Inferred as `1 | 2`

-- Aliases might use generics too. Note the cast to perform the conversions.

---@alias collection<T> set<T>

---@type collection<1 | 2>
local collection = (create_set({3, 4}) --[[@as collection]])

-- There are plenty of documentation-like annotations.

---Old obsolete method. Do not use it.
---
---This method is show by LSP. But its completions use the strikethrough font.
---
---@deprecated
---@return integer
local function old_method() end

---New method referencing the old one.
---
---@see old_method Old version of the method.
local function new_method() end
