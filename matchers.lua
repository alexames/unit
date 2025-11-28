-- matchers.lua
-- Common matcher predicates for assertions
--
-- @module unit.matchers

local llx = require 'llx'
local isinstance = llx.isinstance

--- Converts a table to a formatted string for display.
local function table_to_string(t)
  local s = '{'
  local first = true
  for k, v in pairs(t) do
    if first then
      s = s .. tostring(k) .. ' = ' .. tostring(v)
      first = false
    else
      s = s .. ', ' .. tostring(k) .. ' = ' .. tostring(v)
    end
  end
  return s .. '}'
end

--- Negates a matcher predicate.
-- @param predicate The matcher to negate
-- @return A new matcher predicate
function Not(predicate)
  return function(actual)
    local result, act, msg, nmsg, exp = predicate(actual)
    return not result, act, nmsg, msg, exp
  end
end

--- Checks equality with expected value.
function Equals(expected)
  return function(actual)
    return actual == expected,
           tostring(actual),
           'be equal to',
           'be not equal to',
           tostring(expected)
  end
end

--- Checks if actual > expected
function GreaterThan(expected)
  return function(actual)
    return actual > expected,
           tostring(actual),
           'be greater than',
           'be not greater than',
           tostring(expected)
  end
end

--- Checks if actual >= expected
function GreaterThanOrEqual(expected)
  return function(actual)
    return actual >= expected,
           tostring(actual),
           'be greater than or equal to',
           'be not greater than or equal to',
           tostring(expected)
  end
end

--- Checks if actual < expected
function LessThan(expected)
  return function(actual)
    return actual < expected,
           tostring(actual),
           'be less than',
           'be not less than',
           tostring(expected)
  end
end

--- Checks if actual <= expected
function LessThanOrEqual(expected)
  return function(actual)
    return actual <= expected,
           tostring(actual),
           'be less than or equal to',
           'be not less than or equal to',
           tostring(expected)
  end
end

--- Checks if actual string starts with expected prefix.
function StartsWith(expected)
  return function(actual)
    return actual:startswith(expected),
           tostring(actual),
           'start with',
           'not start with',
           tostring(expected)
  end
end

--- Checks if actual string ends with expected suffix.
function EndsWith(expected)
  return function(actual)
    return actual:endswith(expected),
           tostring(actual),
           'end with',
           'not end with',
           tostring(expected)
  end
end

--- Checks if actual is of expected type/class.
function IsOfType(expected)
  return function(actual)
    return isinstance(actual, expected),
           tostring(actual),
           'be of type',
           'not be of type',
           tostring(expected)
  end
end

--- Applies a matcher element-wise to two lists.
-- @param predicate_generator Function producing matchers
-- @param expected The expected list
function Listwise(predicate_generator, expected)
  return function(actual)
    local result = true
    local act, msg, nmsg, exp
    local act_list, exp_list = {}, {}
    local largest_len = math.max(#actual, #expected)
    for i=1, largest_len do
      local predicate = predicate_generator(expected[i])
      local local_result
      local_result, act, msg, nmsg, exp = predicate(actual[i])
      act_list[i], exp_list[i] = act, exp
      result = result and local_result
    end
    return result,
           '{' .. (','):join(act_list) .. '}',
           msg .. ' the value at every index of',
           'not to ' .. msg .. ' the value at every index of',
           '{' .. (','):join(exp_list) .. '}'
  end
end

--- Gathers keys from multiple tables.
local function collect_keys(out, ...)
  for _, t in ipairs{...} do
    for k in pairs(t) do
      out[k] = true
    end
  end
  return out
end

--- Applies a matcher key-wise to two tables.
-- @param predicate_generator Function producing matchers
-- @param expected The expected table
function Tablewise(predicate_generator, expected)
  return function(actual)
    local result = true
    local act, msg, nmsg, exp
    local act_list, exp_list = {}, {}
    local keys = collect_keys({}, actual, expected)
    for k in pairs(keys) do
      local predicate = predicate_generator(expected[k])
      local local_result
      local_result, act, msg, nmsg, exp = predicate(actual[k])
      result = result and local_result
    end
    return result,
           table_to_string(actual),
           msg .. ' the value at every key of',
           'not to ' .. msg .. ' the value at every key of',
           table_to_string(expected)
  end
end

--- Checks if value is within epsilon of expected (floating point comparison)
function Near(expected, epsilon)
  return function(actual)
    local diff = math.abs(actual - expected)
    return diff <= epsilon,
           tostring(actual),
           string.format('be within %s of', tostring(epsilon)),
           string.format('not be within %s of', tostring(epsilon)),
           tostring(expected)
  end
end

--- Checks if value is NaN
function IsNaN()
  return function(actual)
    local is_nan = actual ~= actual
    return is_nan,
           tostring(actual),
           'be NaN',
           'not be NaN',
           'NaN'
  end
end

--- Checks if value > 0
function IsPositive()
  return function(actual)
    return actual > 0,
           tostring(actual),
           'be positive',
           'not be positive',
           '> 0'
  end
end

--- Checks if value < 0
function IsNegative()
  return function(actual)
    return actual < 0,
           tostring(actual),
           'be negative',
           'not be negative',
           '< 0'
  end
end

--- Checks if value is between min and max (inclusive)
function IsBetween(min, max)
  return function(actual)
    return actual >= min and actual <= max,
           tostring(actual),
           string.format('be between %s and %s', tostring(min), tostring(max)),
           string.format('not be between %s and %s', tostring(min), tostring(max)),
           string.format('[%s, %s]', tostring(min), tostring(max))
  end
end

--- Checks if string contains substring
function Contains(substring)
  return function(actual)
    local contains = type(actual) == 'string' and actual:find(substring, 1, true) ~= nil
    return contains,
           tostring(actual),
           'contain',
           'not contain',
           tostring(substring)
  end
end

--- Checks if string matches pattern
function Matches(pattern)
  return function(actual)
    local matches = type(actual) == 'string' and actual:match(pattern) ~= nil
    return matches,
           tostring(actual),
           'match pattern',
           'not match pattern',
           tostring(pattern)
  end
end

--- Checks if string or collection is empty
function IsEmpty()
  return function(actual)
    local is_empty = false
    if type(actual) == 'string' then
      is_empty = #actual == 0
    elseif type(actual) == 'table' then
      is_empty = next(actual) == nil
    end
    return is_empty,
           tostring(actual),
           'be empty',
           'not be empty',
           '{} or ""'
  end
end

--- Checks if string has specific length
function HasLength(n)
  return function(actual)
    local has_length = type(actual) == 'string' and #actual == n
    return has_length,
           tostring(actual),
           'have length',
           'not have length',
           tostring(n)
  end
end

--- Checks if collection has specific size
function HasSize(n)
  return function(actual)
    local size = 0
    if type(actual) == 'table' then
      for _ in pairs(actual) do
        size = size + 1
      end
    end
    return size == n,
           tostring(actual),
           'have size',
           'not have size',
           tostring(n)
  end
end

--- Checks if collection contains element
function ContainsElement(element)
  return function(actual)
    local contains = false
    if type(actual) == 'table' then
      for _, v in pairs(actual) do
        if v == element then
          contains = true
          break
        end
      end
    end
    return contains,
           tostring(actual),
           'contain element',
           'not contain element',
           tostring(element)
  end
end

--- Checks if all matchers pass
function AllOf(...)
  local matchers = {...}
  return function(actual)
    for _, matcher in ipairs(matchers) do
      local result = matcher(actual)
      if not result then
        return false,
               tostring(actual),
               'match all conditions',
               'not match all conditions',
               'all matchers'
      end
    end
    return true,
           tostring(actual),
           'match all conditions',
           'not match all conditions',
           'all matchers'
  end
end

--- Checks if any matcher passes
function AnyOf(...)
  local matchers = {...}
  return function(actual)
    for _, matcher in ipairs(matchers) do
      local result = matcher(actual)
      if result then
        return true,
               tostring(actual),
               'match any condition',
               'not match any condition',
               'any matcher'
      end
    end
    return false,
           tostring(actual),
           'match any condition',
           'not match any condition',
           'any matcher'
  end
end

return {
  Not=Not,
  Equals=Equals,
  GreaterThan=GreaterThan,
  GreaterThanOrEqual=GreaterThanOrEqual,
  LessThan=LessThan,
  LessThanOrEqual=LessThanOrEqual,
  StartsWith=StartsWith,
  EndsWith=EndsWith,
  IsOfType=IsOfType,
  Listwise=Listwise,
  Tablewise=Tablewise,
  Near=Near,
  IsNaN=IsNaN,
  IsPositive=IsPositive,
  IsNegative=IsNegative,
  IsBetween=IsBetween,
  Contains=Contains,
  Matches=Matches,
  IsEmpty=IsEmpty,
  HasLength=HasLength,
  HasSize=HasSize,
  ContainsElement=ContainsElement,
  AllOf=AllOf,
  AnyOf=AnyOf,
}
