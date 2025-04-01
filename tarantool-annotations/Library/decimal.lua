---@meta

---# Builtin `decimal` module
---
---The `decimal` module has functions for working with exact numbers.
---
---This is important when numbers are large or even the slightest inaccuracy is unacceptable.
---
---**Example:** Lua calculates `0.16666666666667 * 6` with floating-point so the result is 1.
---
---But with the decimal module (using `decimal.new` to convert the number to decimal type) `decimal.new('0.16666666666667') * 6` is 1.00000000000002.
local decimal = {}

---@alias decimal_like decimal | string | number

---@class decimal
---@operator unm: decimal
---@operator add(decimal_like): decimal
---@operator sub(decimal_like): decimal
---@operator mul(decimal_like): decimal
---@operator div(decimal_like): decimal
---@operator mod(decimal_like): decimal
---@operator pow(decimal_like): decimal
local decimal_obj = {}

---Returns absolute value of a decimal number.
---
---**Example:** if `a` is `-1` then `decimal.abs(a)` returns `1`.
---
---@param n decimal_like
---@return decimal
function decimal.abs(n) end

---Returns e raised to the power of a decimal number.
---
---**Example:** if `a` is `1` then `decimal.exp(a)` returns `2.7182818284590452353602874713526624978`.
---
---Compare `math.exp(1)` from the Lua math library, which returns `2.718281828459`.
---
---@param n decimal_like
---@return decimal
function decimal.exp(n) end

---Check if the object is decimal.
---
---Returns `true` if the specified value is a decimal, and `false` otherwise.
---
---**Example:** if `a` is `123` then `decimal.is_decimal(a)` returns `false`.
---
---If `a` is `decimal.new(123)` then `decimal.is_decimal(a)` returns `true`.
---
---@param n any
---@return boolean
function decimal.is_decimal(n) end

---Get natural logarithm of a decimal number.
---
---**Example:** if `a` is `1` then `decimal.ln(a)` returns `0`.
---
---@param n decimal_like
---@return decimal
function decimal.ln(n) end

---Get the value of the input as a decimal number.
---
---**Example:** if `a` is `1E-1` then `decimal.new(a)` returns `0.1`.
---
---@param n decimal_like
---@return decimal
function decimal.new(n) end


---Get the number of digits of a decimal number.
---
---**Example:** if `a` is `123.4560` then `decimal.precision(a)` returns `7`.
---
---@param n decimal_like
---@return number
function decimal.precision(n) end

---Evaluate rounding or padding to a fixed amount of the post-decimal digits of a decimal number.
---
---If the number of post-decimal digits is greater than new-scale, then rounding occurs. The rounding rule is: round half away from zero.
---
---If the number of post-decimal digits is less than new-scale, then padding of zeros occurs.
---
---**Example:** if `a` is `-123.4550` then `decimal.rescale(a, 2)`  returns `-123.46`, and `decimal.rescale(a, 5)` returns `-123.45500`.
---
---@param n decimal
---@param new_scale number
---@return decimal
function decimal.rescale(n, new_scale) end

---Get the number of post-decimal digits of a decimal number.
---
---**Example:** if `a` is `123.4560` then `decimal.scale(a)` returns `4`.
---
---@param n decimal_like
---@return number scale
function decimal.scale(n, new_scale) end

---Get the number of digits of a decimal number.
---
---**Example:** if `a` is `123.4560` then `decimal.precision(a)` returns `7`.
---
---@param n decimal_like
---@return decimal
function decimal.log10(n) end

---Calculate the square root of a decimal number.
---
---**Example:** if `a` is `2` then `decimal.sqrt(a)` returns `1.4142135623730950488016887242096980786`.
---
---@param n decimal_like
---@return decimal
function decimal.sqrt(n) end

---Remove trailing post-decimal zeros of a decimal number.
---
---**Example:** if `a` is `2.20200` then `decimal.trim(a)` returns `2.202`.
---
---@param n decimal
---@return decimal
function decimal.trim(n) end

return decimal
