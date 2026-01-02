-- init.lua
-- Entry point for the unit testing framework
--
-- @module unit

local mock = require 'unit.mock'
local runner = require 'unit.runner'
local test = require 'unit.test'
local test_api = require 'unit.test_api'
local matchers = require 'unit.matchers'


--- Unit testing framework root module.
-- Provides access to core test API, mocks, test registration, and execution.
--
-- @usage
-- local unit = require 'unit'
-- unit.describe('MyTest', function()
--   unit.it('should work', function()
--     unit.expect(1 + 1).to.be_equal_to(2)
--   end)
-- end)
local test_env = {
  -- Mocks
  Mock = mock.Mock,
  spy_on = mock.spy_on,
  spyOn = mock.spy_on,  -- Alias for camelCase compatibility

  -- Test registration and execution
  run_unit_tests = runner.run_unit_tests,
  test_class = runner.test_class,
  Test = test.Test,
  test = test.test,

  -- Test API
  describe = test_api.describe,
  it = test_api.it,
  expect = test_api.expect,
  before_each = test_api.before_each,
  after_each = test_api.after_each,
  before_all = test_api.before_all,
  after_all = test_api.after_all,
  global_before_all = test_api.global_before_all,
  global_after_all = test_api.global_after_all,
  run_tests = test_api.run_tests,
  matchers = test_api.matchers,

  -- Matcher functions (PascalCase for compatibility with test files)
  Equals = matchers.equals,
  GreaterThan = matchers.greater_than,
  GreaterThanOrEqual = matchers.greater_than_or_equal,
  LessThan = matchers.less_than,
  LessThanOrEqual = matchers.less_than_or_equal,
  StartsWith = matchers.starts_with,
  EndsWith = matchers.ends_with,
  IsOfType = matchers.is_of_type,
  Near = matchers.near,
  IsNaN = matchers.is_nan,
  IsPositive = matchers.is_positive,
  IsNegative = matchers.is_negative,
  IsBetween = matchers.is_between,
  Contains = matchers.contains,
  Matches = matchers.matches,
  IsEmpty = matchers.is_empty,
  HasLength = matchers.has_length,
  HasSize = matchers.has_size,
  ContainsElement = matchers.contains_element,
  AllOf = matchers.all_of,
  AnyOf = matchers.any_of,
}

local function create_test_env(fallback_env)
  return setmetatable(test_env, {
    __index = fallback_env,
    __newindex = fallback_env,
  })
end

test_env.create_test_env = create_test_env

return test_env