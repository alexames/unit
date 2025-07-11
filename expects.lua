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
  local result, act, msg, nmsg, exp = predicate(actual, false)
  if not result then
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

--- Asserts that the value is truthy
function EXPECT_TRUTHY(value, level)
  level = level or 3
  EXPECT_TRUE(truthy(value), level)
end

--- Asserts that the value is falsey
function EXPECT_FALSEY(value, level)
  level = level or 3
  EXPECT_FALSE(truthy(value), level)
end

--- Asserts that the function errors when called
function EXPECT_ERROR(fn, level, ...)
  local successful, exception = pcall(fn, ...)
  EXPECT_FALSEY(successful, level)
end

return {
  EXPECT_THAT=EXPECT_THAT,
  EXPECT_TRUE=EXPECT_TRUE,
  EXPECT_FALSE=EXPECT_FALSE,
  EXPECT_EQ=EXPECT_EQ,
  EXPECT_NE=EXPECT_NE,
}
