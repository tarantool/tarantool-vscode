---@meta

-- For sure, this module is the thickest out of all.
-- At some moment I decided to track the features required for implementing the
-- type annotations for that module here. At the very beginning (+) means that
-- it is (kind of) supported right now.
--
-- To be able to provide exact type annotations at their best you need.
-- * (+) Generics at all.
-- * (+) Support inferring generic types from `self`.
-- * (+-) Support inferring generics from function arguments and return types.
--   - This also requires some non-trivial types support! I suppose no one
--     supposes inference of generics from the { [K]: V } table types in such
--     small community like Lua.
-- * (-+) Support inferring for-range types from custom types.
--    - Better for it to be possible class overload since we actually represent
--      the iterator as a table { gen: X, state: Y, param: Z }.
--    - Oh yes and even though I upstreamed this feature we still need to
--      support generic generator-like functions and overloads too!
-- * (-) Support inferring generics from other provided generic arguments within
--   the same call.
-- * (-) Complete support of variadic generics including unpacking them into the
--   function arguments.
--     - Ah, yes, iterators might represent tuple of (any???) size. Arrays
--       and strings represent 1-size tuple, tables - 2-size tuple. But we can
--       extend them using `:map()`.
-- * (-) Variadic generic unions (for something like `fun.chain()`).
--
-- GENERICS! GENERICS! GENERICS!!!!!!!!!
--
-- I've tried a lot of attempts to deal with what we have since patches within
-- the related LSP patches become hard to deal with really soon. Probably it all
-- might be done with one skilled Hindley-Milney type system enjoyer or whatever
-- but I don't any of them with interest in Lua.
--
-- Nevertheless it already allows you rather good support of basic type
-- checking making Lua less-suck for the ones who love statically typing stuff.

---# Builtin `fun` module.
---
---Luafun, also known as the Lua Functional Library, takes advantage of the features of LuaJIT to help users create complex functions.
---
---Inside the module are "sequence processors" such as `map`, `filter`, `reduce`, `zip` -- they take a user-written function as an argument and run it against every element in a sequence, which can be faster or more convenient than a user-written loop.
---
---Inside the module are "generators" such as `range`, `tabulate`, and `rands` -- they return a bounded or boundless series of values. Within the module are "reducers", "filters", "composers" ... or, in short, all the important features found in languages like Standard ML, Haskell, or Erlang.
---
---The full documentation is [on the luafun section of github](https://luafun.github.io/).
---
---However, the first chapter can be skipped because installation is already done, it's inside Tarantool. All that is needed is the usual `require` request. After that, all the operations described in the Lua fun manual will work, provided they are preceded by the name returned by the `require` request. For example:
---
--- ```tarantoolsession
--- tarantool> fun = require('fun')
--- ---
--- ...
---
--- tarantool> for _k, a in fun.range(3) do
--- >   print(a)
--- > end
--- 1
--- 2
--- 3
--- ---
--- ...
--- ```
local fun = {}

---@class fun.iterator<A, B>
local iterator = {}

---*Documentation is not provided yet.*
---
function fun.wrap(gen, param, state) end

---*Documentation is not provided yet.*
---
---@return any
function iterator:unwrap() end

---@generic A, B
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(g: A[]): fun.iterator<A, nil>
---@overload fun(g: string): fun.iterator<string, nil>
function fun.iter(g) end

---@generic A, B
---@param f fun(a: A, b: B)
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(f: fun(a: A), g: A[]): fun.iterator<A, nil>
---@overload fun(f: fun(a: string), g: string): fun.iterator<string, nil>
function fun.each(f, g) end
fun.for_each = fun.each
fun.foreach = fun.each

---@param f fun(a: A, b: B)
---@return fun.iterator<A, B>
function iterator:each(f) end
iterator.for_each = iterator.each
iterator.foreach = iterator.each

---The iterator to create arithmetic progressions.
---
---Iteration values are generated within closed interval [start, stop] (i.e. stop is included).
---
---@param start number
---@param stop? number (default: start)
---@param step? number (default: 1)
---@return fun.iterator<number, nil>
function fun.range(start, stop, step) end

---The iterator returns values over and over again indefinitely.
---
---All values that passed to the iterator are returned as-is during the iteration.
---
---@generic A, B
---@param a? A
---@param b? B
---@return fun.iterator<A, B>
function fun.duplicate(a, b) end
fun.replicate = fun.duplicate
fun.xrepeat = fun.duplicate

---The iterator that returns fun(0), fun(1), fun(2), ... values indefinitely.
---
---@generic A, B
---@param f fun(n: integer): A, B
---@return fun.iterator<A, B>
function fun.tabulate(f) end

---The iterator returns 0 indefinitely.
---
---@return fun.iterator<0, nil>
function fun.zeros() end

---The iterator that returns 1 indefinitely.
---
---@return fun.iterator<1, nil>
function fun.ones() end

---The iterator returns random values using math.random().
---
---If the n and m are set then the iterator returns pseudo-random integers in the [n, m) interval (i.e. m is not included)
---
---If the m is not set then the iterator generates pseudo-random integers in the [0, n) interval.
---
---@param n integer
---@param m? integer
---@return fun.iterator<integer, nil>
function fun.rands(n, m) end

---This function returns the n-th element of gen, param, state iterator.
---
---If the iterator does not have n items then nil is returned.
---
---@generic A, B
---@param n integer
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return A?
---@return B?
---@overload fun(n: integer, g: A[]): A?
---@overload fun(n: integer, g: string): string?
function fun.nth(n, g) end

---This function returns the n-th element of iterator.
---
---@param n integer a sequential number (indexed starting from 1, like Lua tables)
---@return A? nth_element
---@return B? nth_element
function iterator:nth(n) end

---Extract the first element of gen, param, state iterator. If the iterator is empty then an error is raised.
---
---@generic A, B
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return A
---@return B
---@overload fun(g: A[]): A
---@overload fun(g: string): string
function fun.head(g) end
fun.car = fun.head

---Extract the first element from the iterator.
---
---If the iterator is empty then an error is raised.
---
---@return A
---@return B
function iterator:head() end
iterator.car = iterator.head

---Return a copy of gen, param, state iterator without its first element.
---
---If the iterator is empty then an empty iterator is returned.
---
---@generic A, B
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(g: A[]): fun.iterator<A, nil>
---@overload fun(g: string): fun.iterator<string, nil>
function fun.tail(g) end
fun.cdr = fun.tail

---Return a copy of gen, param, state iterator without its first element.
---
---If the iterator is empty then an empty iterator is returned.
---
---@return fun.iterator<A, B>
function iterator:tail() end
iterator.cdr = iterator.tail

---@generic A, B
---@param n integer
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(n: integer, g: A[]): fun.iterator<A, nil>
---@overload fun(n: integer, g: string): fun.iterator<string, nil>
function fun.take_n(n, g) end

---@param n integer a number of elements to take
---@return fun.iterator<A, B>
function iterator:take_n(n) end

---@alias fun.predicate<A, B> fun(a: A, b: B): boolean?

---Returns an iterator on the longest prefix of gen, param, state elements that satisfy predicate.
---
---@generic A, B
---@param predicate fun.predicate<A, B>
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(predicate: fun.predicate<A, nil>, g: A[]): fun.iterator<A, nil>
---@overload fun(predicate: fun.predicate<string, nil>, g: string): fun.iterator<string, nil>
function fun.take_while(predicate, g) end

---Returns an iterator on the longest prefix of the iterator's elements that satisfy predicate.
---
---@param predicate fun.predicate<A, B>
---@return fun.iterator<A, B>
function iterator:take_while(predicate) end

---Alias for `fun.take_while` and `fun.take_n`.
---
---@generic A, B
---@param n_or_predicate fun.predicate<A, B> | integer
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(n_or_predicate: fun.predicate<A, nil> | integer, g: A[]): fun.iterator<A, nil>
---@overload fun(n_or_predicate: fun.predicate<string, nil> | integer, g: string): fun.iterator<string, nil>
function fun.take(n_or_predicate, g) end

---Alias for `i:take_while` and `i:take_n`.
---
---@param n_or_predicate fun.predicate<A, B> | integer
---@return fun.iterator<A, B>
function iterator:take(n_or_predicate) end

---@generic A, B
---@param n integer
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(n: integer, g: A[]): fun.iterator<A, nil>
---@overload fun(n: integer, g: string): fun.iterator<string, nil>
function fun.drop_n(n, g) end

---Drop n elements out of an iterator.
---
---@param n integer a number of elements to drop
---@return fun.iterator<A, B>
function iterator:drop_n(n) end

---Returns an iterator of gen, param, state after skipping the longest prefix of elements that satisfy predicate.
---
---@generic A, B
---@param predicate fun.predicate<A, B>
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(predicate: fun.predicate<A, nil>, g: A[]): fun.iterator<A, nil>
---@overload fun(predicate: fun.predicate<string, nil>, g: string): fun.iterator<string, nil>
function fun.drop_while(predicate, g) end

---Returns an iterator of gen, param, state after skipping the longest prefix of elements that satisfy predicate.
---
---@param predicate fun.predicate<A, B>
---@return fun.iterator<A, B>
function iterator:drop_while(predicate) end

---Alias for `fun.drop_while` and `fun.drop_n`
---
---
---@generic A, B
---@param n_or_predicate fun.predicate<A, B> | integer
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(n_or_predicate: fun.predicate<A, nil> | integer, g: A[]): fun.iterator<A, nil>
---@overload fun(n_or_predicate: fun.predicate<string, nil> | integer, g: string): fun.iterator<string, nil>
function fun.drop(n_or_predicate, g) end

---Alias for `fun.iterator:drop_while` and `fun.iterator:drop_n`
---
---@param n_or_predicate fun.predicate<A, B> | integer
---@return fun.iterator<A, B>
function iterator:drop(n_or_predicate) end

---Return an iterator pair where the first operates on the longest prefix (possibly empty) of gen, param, state iterator
---of elements that satisfy predicate and second operates the remainder of gen, param, state iterator.
---
---Equivalent to:
--- ```lua
---  return take(n_or_fun, g), drop(n_or_fun, g, p, s);
--- ```
---
---@generic A, B
---@param n_or_fun fun.predicate<A, B> | integer
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(n_or_fun: fun.predicate<A, nil> | integer, g: A[]): (fun.iterator<A, nil>, fun.iterator<A, nil>)
---@overload fun(n_or_fun: fun.predicate<string, nil> | integer, g: string): (fun.iterator<string, nil>, fun.iterator<string, nil>)
function fun.split(n_or_fun, g) end
fun.span = fun.split
fun.split_at = fun.split

---Return an iterator pair where the first operates on the longest prefix (possibly empty) of gen, param, state iterator of elements that satisfy predicate and second operates the remainder of gen, param, state iterator.
---
---@param n_or_fun fun.predicate<A, B> | integer
---@return fun.iterator<A, B>, fun.iterator<A, B>
function i:split(n_or_fun) end
i.span = i.split
i.split_at = i.split

---Find an index of an element.
---
---The function returns the position of the first element in the given iterator which is equal (using ==) to the query element, or nil if there is no such element.
---
---@generic A, B
---@param x A
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(x: A, g: A[]): fun.iterator<A, nil>
---@overload fun(x: string, g: string): fun.iterator<string, nil>
function fun.index(x, g) end
fun.index_of = fun.index
fun.elem_index = fun.index

---Find an index of an element.
---
---The function returns the position of the first element in the given iterator which is equal (using ==) to the query element, or nil if there is no such element.
---
---@param x A a value to find
---@return integer? position
function iterator:index(x) end

---The function returns an iterator to positions of elements which equals to the query element.
---
---@generic A, B
---@param x A
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<integer, nil>
---@overload fun(x: A, g: A[]): fun.iterator<integer, nil>
---@overload fun(x: string, g: string): fun.iterator<integer, nil>
function fun.indexes(x, g) end
fun.elem_indexes = fun.indexes
fun.indices = fun.indexes
fun.elem_indices = fun.indexes

---The function returns an iterator to positions of elements which equals to the query element.
---
---@param x A a value to find
---@return fun.iterator<integer, nil>
function iterator:indexes(x) end
iterator.elem_indexes = iterator.indexes
iterator.indices = iterator.indexes
iterator.elem_indices = iterator.indexes

---Return a new iterator of those elements that satisfy the predicate.
---
---@generic A, B
---@param predicate fun.predicate<A, B>
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(predicate: fun.predicate<A, nil>, g: A[]): fun.iterator<A, nil>
---@overload fun(predicate: fun.predicate<string, nil>, g: string): fun.iterator<string, nil>
function fun.filter(predicate, g) end
fun.remove_if = fun.filter

---Return a new iterator of those elements that satisfy the predicate.
---
---@param predicate fun.predicate<A, B>
---@return fun.iterator<A, B>
function iterator:filter(predicate) end
iterator.remove_if = iterator.filter

---Return a new iterator of those elements that satisfy the predicate.
---
---@generic A, B
---@param regex_or_predicate string | fun.predicate<A, B>
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>
---@overload fun(regex_or_predicate: string | fun.predicate<A, nil>, g: A[]): fun.iterator<A, nil>
---@overload fun(regex_or_predicate: string | fun.predicate<string, nil>, g: string): fun.iterator<string, nil>
function fun.grep(regex_or_predicate, g) end

---Return a new iterator of those elements that satisfy the predicate.
---
---@param regex_or_predicate string | fun.predicate<A, B>
---@return fun.iterator<A, B>
function iterator:grep(regex_or_predicate) end

---The function returns two iterators where elements do and do not satisfy the predicate.
---
---The function make a clone of the source iterator.
---Iterators especially returned in tables to work with zip() and other functions.
---
---@generic A, B
---@param predicate fun.predicate<A, B>
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<A, B>, fun.iterator<A, B>
---@overload fun(predicate: fun.predicate<A, nil>, g: A[]): fun.iterator<A, nil>, fun.iterator<A, nil>
---@overload fun(predicate: fun.predicate<string, nil>, g: string): fun.iterator<string, nil>, fun.iterator<string, nil>
function fun.partition(predicate, g) end

---The function returns two iterators where elements do and do not satisfy the predicate.
---
---The function make a clone of the source iterator.
---Iterators especially returned in tables to work with zip() and other functions.
---
---@param predicate fun.predicate<A, B>
---@return fun.iterator<A, B>, fun.iterator<A, B>
function iterator:partition(predicate) end

---The function reduces the iterator from left to right using the binary operator accfun and the initial value initval
---
---@generic R, A, B
---@param acc fun(acc: R, a: A, b: B): R an accumulating function
---@param initval R an initial value that passed to accfun on the first iteration
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return R
---@overload fun(acc: fun(acc: R, a: A): R, initval: R, g: A[]): R
---@overload fun(acc: fun(acc: R, a: string): R, initval: R, g: string): R
function fun.reduce(acc, initval, g) end
fun.foldl = fun.reduce

---The function reduces the iterator from left to right using the binary operator accfun and the initial value initval
---
---@generic R
---@param acc fun(acc: R, a: A, b: B): R an accumulating function
---@param initval R an initial value that passed to accfun on the first iteration
---@return R
function iterator:reduce(acc, initval) end
iterator.foldl = iterator.reduce

---Returns a number of elements in gen, param, state iterator.
---
---@generic A, B
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return integer length
---@overload fun(g: A[]): integer
---@overload fun(g: string): integer
function fun.length(g) end

---Returns a number of elements in iterator.
---
---@return integer length
function iterator:length() end

---Checks whether iterator has any elements inside.
---
---@generic A, B
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return boolean
---@overload fun(g: A[]): boolean
---@overload fun(g: string): boolean
function fun.is_null(g) end

---Checks whether iterator has any elements inside.
---
---@return boolean is_empty
function iterator:is_null() end

---The function takes two iterators and returns true if the first iterator is a prefix of the second.
---
---The implementation of this method is somewhat doubtful. It checks only first 10 items of both iterators.
---
---@deprecated
---@generic A, B
---@param iter_x fun.iterator<A, B>
---@param iter_y fun.iterator<A, B>
---@return boolean? is_prefix
function fun.is_prefix_of(iter_x, iter_y) end

---Returns true if all return values of iterator satisfy the predicate.
---
---@generic A, B
---@param predicate fun.predicate<A, B>
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return boolean
---@overload fun(predicate: fun.predicate<A, nil>, g: A[]): boolean
---@overload fun(predicate: fun.predicate<string, nil>, g: string): boolean
function fun.all(predicate, g) end
fun.every = fun.all

---Returns true if all return values of iterator satisfy the predicate.
---
---@param predicate fun.predicate<A, B>
---@return boolean satisfied
function iterator:all(predicate) end
iterator.every = iterator.all

---Returns true if at least one return values of iterator satisfy the predicate.
---
---@generic A, B
---@param predicate fun.predicate<A, B>
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return boolean
---@overload fun(predicate: fun.predicate<A, nil>, g: A[]): boolean
---@overload fun(predicate: fun.predicate<string, nil>, g: string): boolean
function fun.any(predicate, g) end
fun.some = fun.any

---Returns true if at least one return values of iterator satisfy the predicate.
---
---@param predicate fun.predicate<A, B>
---@return boolean one_is_satisfied
function iterator:any(predicate) end
iterator.some = iterator.any

---Sum up all iteration values.
---
---@param g number[] | fun.iterator<number, nil>
---@return number
function fun.sum(g) end

---Sum up all iteration values.
---
---@return number sum
function iterator:sum() end

---Multiply all iteration values.
---
---@param g number[] | fun.iterator<number, nil>
---@return number
function fun.product(g) end

---Multiply all iteration values.
---
---@return number product
function iterator:product() end

---Return a minimum value from the iterator using operator.min() or < for numbers and other types respectively.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@generic A
---@param g A[] | fun.iterator<A, nil>
---@return A
function fun.min(g) end
fun.minimum = fun.min

---Return a minimum value from the iterator using operator.min() or < for numbers and other types respectively.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@return A minimal
function iterator:min() end
iterator.minimum = iterator.min

---Return a minimum value from the iterator using operator.min() or < for numbers and other types respectively.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@generic A
---@param g A[] | fun.iterator<A, nil>
---@return A
function fun.max(g) end
fun.maximum = fun.max

---Return a minimum value from the iterator using operator.min() or < for numbers and other types respectively.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@return A maximal
function iterator:max() end
iterator.maximum = iterator.max

---@alias fun.comparator<T> fun(a: T, b: T): T

---Return a maximum value from the iterator using the cmp as a > operator.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@generic A
---@param cmp fun.comparator<A>
---@param g A[] | fun.iterator<A, nil>
---@return A
function fun.max_by(cmp, g) end
fun.maximum_by = fun.max_by

---Return a maximum value from the iterator using the cmp as a > operator.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@param cmp fun.comparator<A>
---@return A maximal
function iterator:max_by(cmp) end
iterator.maximum_by = iterator.max_by

---Return a maximum value from the iterator using the cmp as a > operator.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@generic A
---@param cmp fun.comparator<A>
---@param g A[] | fun.iterator<A, nil>
---@return A
function fun.min_by(cmp, g) end
fun.minimum_by = fun.min_by

---Return a maximum value from the iterator using the cmp as a > operator.
---
---The iterator must be non-null, otherwise an error is raised.
---
---@param cmp fun.comparator<A>
---@return A maximal
function iterator:min_by(cmp) end
iterator.minimum_by = iterator.min_by


---Returns a new table (array) from iterated values.
---
---@generic A
---@param g A[] | fun.iterator<A, nil>
---@return A[]
---@overload fun(g: string): string[]
function fun.totable(g) end

---Returns a new table (array) from iterated values.
---
---@return A[]
function iterator:totable() end

---Returns a new table (map) from iterated values.
---
---@generic A, B
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return table<A, B>
function fun.tomap(g) end

---Returns a new table (map) from iterated values.
---
---@return table<A, B>
function iterator:tomap() end

---Return a new iterator by  applying the fun to each element of gen, param, state iterator.
---
---The mapping is performed on the fly and no values are buffered.
---
---@generic A, B, C, D
---@param f fun(a: A, b: B): (C, D)
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<C, D>
---@overload fun(f: fun(a: A): (C, D), g: A[]): fun.iterator<C, D>
---@overload fun(f: fun(a: string): (C, D), g: string): fun.iterator<C, D>
function fun.map(f, g) end

---return a new iterator by applying the fun to each element of gen, param, state iterator.
---
---the mapping is performed on the fly and no values are buffered.
---
---@generic C, D
---@param f fun(a: A, b: B): (C, D)
---@return fun.iterator<C, D>
function iterator:map(f) end

---Return a new iterator by enumerating all elements of the gen, param, state iterator starting from 1.
---
---The mapping is performed on the fly and no values are buffered.
---
---@generic A, B
---@param g table<A, B> | { [A]: B } | fun.iterator<A, B>
---@return fun.iterator<integer, A>
---@overload fun(g: A[]): fun.iterator<integer, A>
---@overload fun(g: string): fun.iterator<integer, string>
function fun.enumerate(g) end

---Return a new iterator by enumerating all elements of the gen, param, state iterator starting from 1.
---
---The mapping is performed on the fly and no values are buffered.
---
---@return fun.iterator<integer, A>
function iterator:enumerate() end

---Return a new iterator where the x value is interspersed between the elements of the source iterator.
---
---The x value can also be added as a last element of returning iterator if the source iterator contains the odd number of elements.
---
function fun.intersperse(x, g) end

---Return a new iterator where the x value is interspersed between the elements of the source iterator.
---
---The x value can also be added as a last element of returning iterator if the source iterator contains the odd number of elements.
---
function iterator:intersperse(x) end

---Return a new iterator where i-th return value contains the i-th element from each of the iterators.
---
---The returned iterator is truncated in length to the length of the shortest iterator.
---
---For multi-return iterators only the first variable is used.
---
function fun.zip(...) end

---Return a new iterator where i-th return value contains the i-th element from each of the iterators.
---
---The returned iterator is truncated in length to the length of the shortest iterator.
---
---For multi-return iterators only the first variable is used.
---
function iterator:zip(...) end

---Make a new iterator that returns elements from {gen, param, state} iterator until the end and then “restart” iteration using a saved clone of {gen, param, state}.
---
---The returned iterator is constant space and no return values are buffered.
---
---Instead of that the function make a clone of the source {gen, param, state} iterator.
---
---Therefore, the source iterator must be pure functional to make an identical clone.
---
---Infinity iterators are supported, but are not recommended.
---
function fun.cycle(g) end

---Make a new iterator that returns elements from {gen, param, state} iterator until the end and then “restart” iteration using a saved clone of {gen, param, state}.
---
---The returned iterator is constant space and no return values are buffered.
---
---Instead of that the function make a clone of the source {gen, param, state} iterator.
---
---Therefore, the source iterator must be pure functional to make an identical clone.
---
---Infinity iterators are supported, but are not recommended.
---
function iterator:cycle(g) end

---Make an iterator that returns elements from the first iterator until it is exhausted, then proceeds to the next iterator, until all of the iterators are exhausted.
---
---Used for treating consecutive iterators as a single iterator.
---
---Infinity iterators are supported, but are not recommended.
function fun.chain(...) end

---Make an iterator that returns elements from the first iterator until it is exhausted, then proceeds to the next iterator, until all of the iterators are exhausted.
---
---Used for treating consecutive iterators as a single iterator.
---
---Infinity iterators are supported, but are not recommended.
function iterator:chain(...) end

fun.op = {}

---Return a < b
---
---@param a any
---@param b any
---@return boolean
function fun.op.lt(a, b) end

---Return a <= b
---
---@param a any
---@param b any
---@return boolean
function fun.op.le(a, b) end

---Return a == b.
---
---@param a any
---@param b any
---@return boolean
function fun.op.eq(a, b) end

---Return a ~= b.
---
---@param a any
---@param b any
---@return boolean
function fun.op.ne(a, b) end

---Return a >= b.
---
---@param a any
---@param b any
---@return boolean
function fun.op.ge(a, b) end

---Return a > b.
---
---@param a any
---@param b any
---@return boolean
function fun.op.gt(a, b) end

---Return a + b.
---
---@param a any
---@param b any
---@return any
function fun.op.add(a, b) end

---Return a / b.
---@param a any
---@param b any
---@return any
function fun.op.div(a, b) end

---Return a % b.
---
---@param a any
---@param b any
---@return any
function fun.op.mod(a, b) end

---Return a * b.
---
---@param a any
---@param b any
---@return any
function fun.op.mul(a, b) end

---Return a ^ b.
---
---@param a any
---@param b any
---@return any
function fun.op.pow(a, b) end

---Return a - b.
---
---@param a any
---@param b any
---@return any
function fun.op.sub(a, b) end

---Return a / b.
---
---@param a any
---@param b any
---@return any
function fun.op.truediv(a, b) end

---Return a..b.
---
---@param a any
---@param b any
---@return string
function fun.op.concat(a, b) end

---Return #a.
---
---@param a any
---@return integer
function fun.op.len(a) end
fun.op.length = fun.op.length


---Return a and b.
---
---@param a any
---@param b any
---@return any
function fun.op.land(a, b) end

---Return a or b.
---
---@param a any
---@param b any
---@return any
function fun.op.lor(a, b) end


---Return not a.
---
---@param a any
---@return boolean
function fun.op.lnot(a) end

---Return not not a.
---
---@param a any
---@return boolean
function fun.op.truth(a) end

---Return -a.
---
---@param a any
---@return any
function fun.op.neq(a) end
fun.op.unm = fun.op.neq

return fun
