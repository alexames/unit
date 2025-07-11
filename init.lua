-- init.lua
-- Entry point for the unit testing framework
--
-- @module unit

local expects = require 'unit.expects'
local matchers = require 'unit.matchers'
local mock = require 'unit.mock'
local runner = require 'unit.runner'
local test = require 'unit.test'


--- Unit testing framework root module.
-- Provides access to core assertions, matchers, mocks, test registration, and execution.
--
-- @usage
-- local unit = require 'unit'
-- unit.EXPECT_EQ(actual, expected)
-- unit.test_class 'MyTest' { ... }
local test_env = {
  -- Assertions
  EXPECT_THAT = expects.EXPECT_THAT,
  EXPECT_TRUE = expects.EXPECT_TRUE,
  EXPECT_FALSE = expects.EXPECT_FALSE,
  EXPECT_EQ = expects.EXPECT_EQ,
  EXPECT_NE = expects.EXPECT_NE,

  -- Matchers
  Not = matchers.Not,
  Equals = matchers.Equals,
  GreaterThan = matchers.GreaterThan,
  GreaterThanOrEqual = matchers.GreaterThanOrEqual,
  LessThan = matchers.LessThan,
  LessThanOrEqual = matchers.LessThanOrEqual,
  StartsWith = matchers.StartsWith,
  EndsWith = matchers.EndsWith,
  IsOfType = matchers.IsOfType,
  Listwise = matchers.Listwise,
  Tablewise = matchers.Tablewise,

  -- Mocks
  Mock = mock.Mock,

  -- Test registration and execution
  run_unit_tests = runner.run_unit_tests,
  test_class = runner.test_class,
  Test = test.Test,
  test = test.test
}

local function create_test_env(fallback_env)
  return setmetatable(test_env, {
    __index = fallback_env,
    __newindex = fallback_env,
  })
end

test_env.create_test_env = create_test_env

return test_env