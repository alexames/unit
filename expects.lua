-- expects.lua
-- Assertion helpers for unit testing
--
-- @module unit.expects
-- @usage
-- local expects = require 'unit.expects'
-- expects.EXPECT_EQ(actual, expected)

local matchers = require 'unit.matchers'
local truthy, falsey = require 'llx.truthy' {'truthy', 'falsey'}

local equals = matchers.equals
local negate = matchers.negate
local less_than = matchers.less_than
local less_than_or_equal = matchers.less_than_or_equal
local greater_than = matchers.greater_than
local greater_than_or_equal = matchers.greater_than_or_equal
local near = matchers.near
local contains = matchers.contains
local matches = matchers.matches
local is_empty = matchers.is_empty
local has_size = matchers.has_size

--- Asserts that a value satisfies the given matcher.
-- @param actual The actual value
-- @param predicate A matcher predicate like equals or negate
-- @param[opt=2] level Stack level for error
-- @param[opt] s Optional string for description
function expect_that(actual, predicate, level, s)
  level = level or 2
  local result = predicate(actual, false)
  if type(result) ~= 'table' or result.pass == nil then
    error('Matcher must return a table with pass, actual, positive_message, negative_message, and expected fields', level)
  end
  if not result.pass then
    error(('expected %s\n  %s\nto %s\n  %s'):format(s or '', result.actual, result.positive_message, result.expected), level)
  end
end

--- Asserts that actual == true
function expect_true(actual, level)
  level = level or 3
  expect_that(actual, equals(true), level)
end

--- Asserts that actual == false
function expect_false(actual, level)
  level = level or 3
  expect_that(actual, equals(false), level)
end

--- Asserts that actual == expected
function expect_eq(actual, expected, level)
  level = level or 3
  expect_that(actual, equals(expected), level)
end

--- Asserts that actual ~= expected
function expect_ne(actual, expected, level)
  level = level or 3
  expect_that(actual, negate(equals(expected)), level)
end

--- Asserts that actual < expected
function expect_lt(actual, expected, level)
  level = level or 3
  expect_that(actual, less_than(expected), level)
end

--- Asserts that actual <= expected
function expect_le(actual, expected, level)
  level = level or 3
  expect_that(actual, less_than_or_equal(expected), level)
end

--- Asserts that actual > expected
function expect_gt(actual, expected, level)
  level = level or 3
  expect_that(actual, greater_than(expected), level)
end

--- Asserts that actual >= expected
function expect_ge(actual, expected, level)
  level = level or 3
  expect_that(actual, greater_than_or_equal(expected), level)
end

--- Asserts that actual is within epsilon of expected
function expect_near(actual, expected, epsilon, level)
  level = level or 3
  expect_that(actual, near(expected, epsilon), level)
end

--- Asserts that value is nil
function expect_nil(value, level)
  level = level or 3
  expect_that(value, equals(nil), level)
end

--- Asserts that value is not nil
function expect_not_nil(value, level)
  level = level or 3
  expect_that(value, negate(equals(nil)), level)
end

--- Asserts that string contains substring
function expect_contains(str, substring, level)
  level = level or 3
  expect_that(str, contains(substring), level)
end

--- Asserts that string matches pattern
function expect_matches(str, pattern, level)
  level = level or 3
  expect_that(str, matches(pattern), level)
end

--- Asserts that collection is empty
function expect_empty(collection, level)
  level = level or 3
  expect_that(collection, is_empty(), level)
end

--- Asserts that collection has size n
function expect_size(collection, n, level)
  level = level or 3
  expect_that(collection, has_size(n), level)
end

--- Asserts that the function does not error when called
function expect_no_error(fn, level, ...)
  level = level or 3
  local successful, exception = pcall(fn, ...)
  if not successful then
    error('expected function not to raise error, but got: ' .. tostring(exception), level)
  end
end

--- Asserts that the function errors when called
function expect_error(fn, expected, level, ...)
  level = level or 3
  local successful, exception = pcall(fn, ...)
  if expected then
    if type(expected) == 'string' and type(exception) == 'string' then
      local path_colon = exception:find(':', 1, true)
      local line_colon = exception:find(':', path_colon + 1, true)
      expect_eq(exception:sub(line_colon + 2), expected, level + 1)
    else
      expect_eq(exception, expected, level + 1)
    end
  end
  if successful then
    error('expected function to raise error', level)
  end
end

--- Asserts that the value is truthy
function expect_truthy(value, level)
  level = level or 3
  expect_true(truthy(value), level)
end

--- Asserts that the value is falsey
function expect_falsey(value, level)
  level = level or 3
  expect_true(falsey(value), level)
end

-- Internal function used by test_api.lua
-- Only export expect_that for internal use
return {
  expect_that=expect_that,
  expect_eq=expect_eq,  -- Used internally by test_api.lua
}
