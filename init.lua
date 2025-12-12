-- init.lua
-- Entry point for the unit testing framework
--
-- @module unit

local expects = require 'unit.expects'
local matchers = require 'unit.matchers'
local mock = require 'unit.mock'
local runner = require 'unit.runner'
local test = require 'unit.test'
local jest_style = require 'unit.jest_style'


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
  EXPECT_LT = expects.EXPECT_LT,
  EXPECT_LE = expects.EXPECT_LE,
  EXPECT_GT = expects.EXPECT_GT,
  EXPECT_GE = expects.EXPECT_GE,
  EXPECT_NEAR = expects.EXPECT_NEAR,
  EXPECT_NIL = expects.EXPECT_NIL,
  EXPECT_NOT_NIL = expects.EXPECT_NOT_NIL,
  EXPECT_CONTAINS = expects.EXPECT_CONTAINS,
  EXPECT_MATCHES = expects.EXPECT_MATCHES,
  EXPECT_EMPTY = expects.EXPECT_EMPTY,
  EXPECT_SIZE = expects.EXPECT_SIZE,
  EXPECT_NO_ERROR = expects.EXPECT_NO_ERROR,
  EXPECT_ERROR = expects.EXPECT_ERROR,
  EXPECT_TRUTHY = expects.EXPECT_TRUTHY,
  EXPECT_FALSEY = expects.EXPECT_FALSEY,

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
  Near = matchers.Near,
  IsNaN = matchers.IsNaN,
  IsPositive = matchers.IsPositive,
  IsNegative = matchers.IsNegative,
  IsBetween = matchers.IsBetween,
  Contains = matchers.Contains,
  Matches = matchers.Matches,
  IsEmpty = matchers.IsEmpty,
  HasLength = matchers.HasLength,
  HasSize = matchers.HasSize,
  ContainsElement = matchers.ContainsElement,
  AllOf = matchers.AllOf,
  AnyOf = matchers.AnyOf,

  -- Mocks
  Mock = mock.Mock,

  -- Test registration and execution
  run_unit_tests = runner.run_unit_tests,
  test_class = runner.test_class,
  Test = test.Test,
  test = test.test,

  -- Jest-style API
  describe = jest_style.describe,
  it = jest_style.it,
  expect = jest_style.expect,
  beforeEach = jest_style.beforeEach,
  afterEach = jest_style.afterEach,
  run_jest_tests = jest_style.run_jest_tests,
  jestMatchers = jest_style.jestMatchers,
}

local function create_test_env(fallback_env)
  return setmetatable(test_env, {
    __index = fallback_env,
    __newindex = fallback_env,
  })
end

test_env.create_test_env = create_test_env

return test_env