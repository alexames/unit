-- expects.lua
-- Assertion helpers for unit testing
--
-- @module unit.expects
-- @usage
-- local expects = require 'unit.expects'
-- expects.EXPECT_EQ(actual, expected)

require 'unit.matchers'
local truthy, falsey = require 'llx.truthy' {'truthy', 'falsey'}

--- Asserts that a value satisfies the given matcher.
-- @param actual The actual value
-- @param predicate A matcher predicate like Equals or Not
-- @param[opt=2] level Stack level for error
-- @param[opt] s Optional string for description
function EXPECT_THAT(actual, predicate, level, s)
  level = level or 2
  local result = predicate(actual, false)
  -- Handle both new table format and legacy 5-value format
  local pass, act, msg, exp
  if type(result) == 'table' and result.pass ~= nil then
    pass = result.pass
    act = result.actual
    msg = result.positive_message
    exp = result.expected
  else
    -- Legacy format: 5 return values
    pass, act, msg, _, exp = result
  end
  if not pass then
    error(('expected %s\n  %s\nto %s\n  %s'):format(s or '', act, msg, exp), level)
  end
end

--- Asserts that actual == true
function EXPECT_TRUE(actual, level)
  level = level or 3
  EXPECT_THAT(actual, Equals(true), level)
end

--- Asserts that actual == false
function EXPECT_FALSE(actual, level)
  level = level or 3
  EXPECT_THAT(actual, Equals(false), level)
end

--- Asserts that actual == expected
function EXPECT_EQ(actual, expected, level)
  level = level or 3
  EXPECT_THAT(actual, Equals(expected), level)
end

--- Asserts that actual ~= expected
function EXPECT_NE(actual, expected, level)
  level = level or 3
  EXPECT_THAT(actual, Not(Equals(expected)), level)
end

--- Asserts that actual < expected
function EXPECT_LT(actual, expected, level)
  level = level or 3
  EXPECT_THAT(actual, LessThan(expected), level)
end

--- Asserts that actual <= expected
function EXPECT_LE(actual, expected, level)
  level = level or 3
  EXPECT_THAT(actual, LessThanOrEqual(expected), level)
end

--- Asserts that actual > expected
function EXPECT_GT(actual, expected, level)
  level = level or 3
  EXPECT_THAT(actual, GreaterThan(expected), level)
end

--- Asserts that actual >= expected
function EXPECT_GE(actual, expected, level)
  level = level or 3
  EXPECT_THAT(actual, GreaterThanOrEqual(expected), level)
end

--- Asserts that actual is within epsilon of expected
function EXPECT_NEAR(actual, expected, epsilon, level)
  level = level or 3
  EXPECT_THAT(actual, Near(expected, epsilon), level)
end

--- Asserts that value is nil
function EXPECT_NIL(value, level)
  level = level or 3
  EXPECT_THAT(value, Equals(nil), level)
end

--- Asserts that value is not nil
function EXPECT_NOT_NIL(value, level)
  level = level or 3
  EXPECT_THAT(value, Not(Equals(nil)), level)
end

--- Asserts that string contains substring
function EXPECT_CONTAINS(str, substring, level)
  level = level or 3
  EXPECT_THAT(str, Contains(substring), level)
end

--- Asserts that string matches pattern
function EXPECT_MATCHES(str, pattern, level)
  level = level or 3
  EXPECT_THAT(str, Matches(pattern), level)
end

--- Asserts that collection is empty
function EXPECT_EMPTY(collection, level)
  level = level or 3
  EXPECT_THAT(collection, IsEmpty(), level)
end

--- Asserts that collection has size n
function EXPECT_SIZE(collection, n, level)
  level = level or 3
  EXPECT_THAT(collection, HasSize(n), level)
end

--- Asserts that the function does not error when called
function EXPECT_NO_ERROR(fn, level, ...)
  level = level or 3
  local successful, exception = pcall(fn, ...)
  if not successful then
    error('expected function not to raise error, but got: ' .. tostring(exception), level)
  end
end

--- Asserts that the function errors when called
function EXPECT_ERROR(fn, expected, level, ...)
  level = level or 3
  local successful, exception = pcall(fn, ...)
  if expected then
    if type(expected) == 'string' and type(exception) == 'string' then
      local path_colon = exception:find(':', 1, true)
      local line_colon = exception:find(':', path_colon + 1, true)
      EXPECT_EQ(exception:sub(line_colon + 2), expected, level + 1)
    else
      EXPECT_EQ(exception, expected, level + 1)
    end
  end
  if successful then
    error('expected function to raise error', level)
  end
end

--- Asserts that the value is truthy
function EXPECT_TRUTHY(value, level)
  level = level or 3
  EXPECT_TRUE(truthy(value), level)
end

--- Asserts that the value is falsey
function EXPECT_FALSEY(value, level)
  level = level or 3
  EXPECT_TRUE(falsey(value), level)
end

return {
  EXPECT_THAT=EXPECT_THAT,
  EXPECT_TRUE=EXPECT_TRUE,
  EXPECT_FALSE=EXPECT_FALSE,
  EXPECT_EQ=EXPECT_EQ,
  EXPECT_NE=EXPECT_NE,
  EXPECT_LT=EXPECT_LT,
  EXPECT_LE=EXPECT_LE,
  EXPECT_GT=EXPECT_GT,
  EXPECT_GE=EXPECT_GE,
  EXPECT_NEAR=EXPECT_NEAR,
  EXPECT_NIL=EXPECT_NIL,
  EXPECT_NOT_NIL=EXPECT_NOT_NIL,
  EXPECT_CONTAINS=EXPECT_CONTAINS,
  EXPECT_MATCHES=EXPECT_MATCHES,
  EXPECT_EMPTY=EXPECT_EMPTY,
  EXPECT_SIZE=EXPECT_SIZE,
  EXPECT_NO_ERROR=EXPECT_NO_ERROR,
  EXPECT_ERROR=EXPECT_ERROR,
  EXPECT_TRUTHY=EXPECT_TRUTHY,
  EXPECT_FALSEY=EXPECT_FALSEY,
}
