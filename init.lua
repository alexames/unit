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
  expect_that = expects.expect_that,
  expect_true = expects.expect_true,
  expect_false = expects.expect_false,
  expect_eq = expects.expect_eq,
  expect_ne = expects.expect_ne,
  expect_lt = expects.expect_lt,
  expect_le = expects.expect_le,
  expect_gt = expects.expect_gt,
  expect_ge = expects.expect_ge,
  expect_near = expects.expect_near,
  expect_nil = expects.expect_nil,
  expect_not_nil = expects.expect_not_nil,
  expect_contains = expects.expect_contains,
  expect_matches = expects.expect_matches,
  expect_empty = expects.expect_empty,
  expect_size = expects.expect_size,
  expect_no_error = expects.expect_no_error,
  expect_error = expects.expect_error,
  expect_truthy = expects.expect_truthy,
  expect_falsey = expects.expect_falsey,

  -- Matchers
  negate = matchers.negate,
  equals = matchers.equals,
  greater_than = matchers.greater_than,
  greater_than_or_equal = matchers.greater_than_or_equal,
  less_than = matchers.less_than,
  less_than_or_equal = matchers.less_than_or_equal,
  starts_with = matchers.starts_with,
  ends_with = matchers.ends_with,
  is_of_type = matchers.is_of_type,
  listwise = matchers.listwise,
  tablewise = matchers.tablewise,
  near = matchers.near,
  is_nan = matchers.is_nan,
  is_positive = matchers.is_positive,
  is_negative = matchers.is_negative,
  is_between = matchers.is_between,
  contains = matchers.contains,
  matches = matchers.matches,
  is_empty = matchers.is_empty,
  has_length = matchers.has_length,
  has_size = matchers.has_size,
  contains_element = matchers.contains_element,
  all_of = matchers.all_of,
  any_of = matchers.any_of,

  -- Mocks
  Mock = mock.Mock,
  spy_on = mock.spy_on,

  -- Test registration and execution
  run_unit_tests = runner.run_unit_tests,
  test_class = runner.test_class,
  Test = test.Test,
  test = test.test,

  -- Jest-style API
  describe = jest_style.describe,
  it = jest_style.it,
  expect = jest_style.expect,
  before_each = jest_style.before_each,
  after_each = jest_style.after_each,
  before_all = jest_style.before_all,
  after_all = jest_style.after_all,
  global_before_all = jest_style.global_before_all,
  global_after_all = jest_style.global_after_all,
  run_jest_tests = jest_style.run_jest_tests,
  jest_matchers = jest_style.jest_matchers,
}

local function create_test_env(fallback_env)
  return setmetatable(test_env, {
    __index = fallback_env,
    __newindex = fallback_env,
  })
end

test_env.create_test_env = create_test_env

return test_env