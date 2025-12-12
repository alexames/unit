-- jest_style.lua
-- Jest-style describe/it/expect API for unit testing
--
-- @module unit.jest_style

local llx = require 'llx'
local test = require 'unit.test'
local expects = require 'unit.expects'
local matchers = require 'unit.matchers'
local truthy, falsey = require 'llx.truthy' {'truthy', 'falsey'}

local class = llx.class

-- Context stack for nested describe blocks
local describe_context_stack = {}

-- Global test suites registered via describe
local jest_test_suites = llx.Table{}

--- Public table for registering jest-style matchers.
-- Users can add their own matchers by assigning to this table.
-- Matchers should be functions that take arguments and return a matcher function.
-- For example: jestMatchers.beEqualTo = matchers.Equals
local jestMatchers = {}

--- Creates an expect object with matcher methods
-- @param actual The actual value to test
-- @return An object with to and toNot properties
local function expect(actual)
  local expect_obj = {
    _actual = actual,
  }

  -- Helper to create a matcher method from a jestMatcher entry
  local function create_matcher_method(matcher_creator, negated)
    if type(matcher_creator) ~= 'function' then
      return nil
    end
    
    return function(...)
      local matcher = matcher_creator(...)
      if negated then
        matcher = matchers.Not(matcher)
      end
      expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
    end
  end

  -- Create proxies that dynamically look up matchers from jestMatchers
  local to_proxy = {}
  setmetatable(to_proxy, {
    __index = function(_, key)
      -- Handle special matchers
      if key == 'throw' then
        return function(expected)
          local level = 3
          if type(expect_obj._actual) ~= 'function' then
            error('throw() expects a function, got ' .. type(expect_obj._actual), level)
          end
          
          local successful, exception = pcall(expect_obj._actual)
          
          -- Expect function to throw
          if expected then
            if type(expected) == 'string' and type(exception) == 'string' then
              local path_colon = exception:find(':', 1, true)
              local line_colon = exception:find(':', path_colon + 1, true)
              if line_colon then
                expects.EXPECT_EQ(exception:sub(line_colon + 2), expected, level + 1)
              else
                expects.EXPECT_EQ(exception, expected, level + 1)
              end
            else
              expects.EXPECT_EQ(exception, expected, level + 1)
            end
          end
          if successful then
            error('expected function to raise error', level)
          end
        end
      elseif key == 'match' then
        return function(matcher_func)
          expects.EXPECT_THAT(expect_obj._actual, matcher_func, 3)
        end
      elseif key == 'satisfy' then
        return function(...)
          expects.EXPECT_THAT(expect_obj._actual, matchers.AllOf(...), 3)
        end
      elseif key == 'satisfyAny' then
        return function(...)
          expects.EXPECT_THAT(expect_obj._actual, matchers.AnyOf(...), 3)
        end
      else
        -- Look up in jestMatchers
        local matcher_creator = jestMatchers[key]
        if matcher_creator then
          return create_matcher_method(matcher_creator, false)
        end
      end
      return nil
    end
  })

  local toNot_proxy = {}
  setmetatable(toNot_proxy, {
    __index = function(_, key)
      -- Handle special matchers
      if key == 'throw' then
        return function(expected)
          local level = 3
          if type(expect_obj._actual) ~= 'function' then
            error('throw() expects a function, got ' .. type(expect_obj._actual), level)
          end
          local successful, exception = pcall(expect_obj._actual)
          if not successful then
            error('expected function not to raise error, but got: ' .. tostring(exception), level)
          end
        end
      elseif key == 'match' then
        return function(matcher_func)
          expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matcher_func), 3)
        end
      elseif key == 'satisfy' then
        return function(...)
          expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.AllOf(...)), 3)
        end
      elseif key == 'satisfyAny' then
        return function(...)
          expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.AnyOf(...)), 3)
        end
      else
        -- Look up in jestMatchers
        local matcher_creator = jestMatchers[key]
        if matcher_creator then
          return create_matcher_method(matcher_creator, true)
        end
      end
      return nil
    end
  })

  expect_obj.to = to_proxy
  expect_obj.toNot = toNot_proxy

  return expect_obj
end

-- Register all built-in matchers
jestMatchers.beEqualTo = matchers.Equals
jestMatchers.beGreaterThan = matchers.GreaterThan
jestMatchers.beGreaterThanOrEqual = matchers.GreaterThanOrEqual
jestMatchers.beLessThan = matchers.LessThan
jestMatchers.beLessThanOrEqual = matchers.LessThanOrEqual
jestMatchers.contain = matchers.Contains
jestMatchers.matchPattern = matchers.Matches
jestMatchers.startWith = matchers.StartsWith
jestMatchers.endWith = matchers.EndsWith
jestMatchers.haveLength = matchers.HasLength
jestMatchers.beEmpty = function() return matchers.IsEmpty() end
jestMatchers.haveSize = matchers.HasSize
jestMatchers.containElement = matchers.ContainsElement
jestMatchers.beNil = function() return matchers.Equals(nil) end
jestMatchers.beTruthy = function()
  return function(actual)
    return truthy(actual),
           tostring(actual),
           'be truthy',
           'be not truthy',
           'truthy value'
  end
end
jestMatchers.beFalsy = function()
  return function(actual)
    return falsey(actual),
           tostring(actual),
           'be falsy',
           'be not falsy',
           'falsy value'
  end
end
jestMatchers.beNear = matchers.Near
jestMatchers.bePositive = function() return matchers.IsPositive() end
jestMatchers.beNegative = function() return matchers.IsNegative() end
jestMatchers.beBetween = matchers.IsBetween
jestMatchers.beNaN = function() return matchers.IsNaN() end
jestMatchers.beOfType = matchers.IsOfType
-- Special matchers that need custom handling (not registered in jestMatchers)
-- These are handled directly in the proxy __index functions

--- Test class for Jest-style tests
local JestTestSuite = class 'JestTestSuite':extends(test.Test) {
  __init = function(self, suite_name, tests)
    test.Test.__init(self)
    self._name = suite_name
    self._jest_tests = tests
    self._tests = self:gather_jest_tests()
  end,

  gather_jest_tests = function(self)
    local result = llx.Table()
    for i, test_case in ipairs(self._jest_tests) do
      result:insert({
        index = i,
        name = {test_case.name},
        func = test_case.func
      })
    end
    return result
  end,
}

--- Registers a test case within the current describe context
-- @param name Test name
-- @param func Test function
local function it(name, func)
  local context = describe_context_stack[#describe_context_stack]
  if not context then
    error('it() must be called within a describe() block', 2)
  end
  table.insert(context.tests, {
    name = name,
    func = func
  })
end

-- Alias for it
local test = it

--- Creates a test suite (describe block)
-- @param name Suite name
-- @param func Function that contains it() calls
local function describe(name, func)
  local context = {
    name = name,
    tests = {},
    setup = llx.noop,
    teardown = llx.noop,
  }
  
  table.insert(describe_context_stack, context)
  
  -- Execute the describe block to collect tests
  local success, err = pcall(func)
  
  table.remove(describe_context_stack)
  
  if not success then
    error('Error in describe block "' .. name .. '": ' .. tostring(err), 2)
  end

  -- Create a test class for this suite
  local suite_class = class(name):extends(JestTestSuite) {
    __init = function(self, suite_name, tests)
      JestTestSuite.__init(self, suite_name, tests)
    end,
  }
  
  -- Store the test data for later instantiation
  suite_class.__jest_tests = context.tests
  suite_class.__jest_setup = context.setup
  suite_class.__jest_teardown = context.teardown
  
  -- Override setup/teardown if provided
  if context.setup ~= llx.noop then
    suite_class.setup = context.setup
  end
  if context.teardown ~= llx.noop then
    suite_class.teardown = context.teardown
  end
  
  jest_test_suites:insert(suite_class)
end

--- Setup function for the current describe block
-- @param func Setup function
local function beforeEach(func)
  local context = describe_context_stack[#describe_context_stack]
  if not context then
    error('beforeEach() must be called within a describe() block', 2)
  end
  context.setup = func
end

--- Teardown function for the current describe block
-- @param func Teardown function
local function afterEach(func)
  local context = describe_context_stack[#describe_context_stack]
  if not context then
    error('afterEach() must be called within a describe() block', 2)
  end
  context.teardown = func
end

--- Runs all Jest-style tests
-- @param[opt] filter A string to match against test suite names
-- @param[opt] logger An optional logger object to capture output
local function run_jest_tests(filter, logger)
  local test_logger = require 'unit.test_logger'
  logger = logger or test_logger.TestLogger()
  local total_failure_count = 0
  local total_test_count = 0

  logger.prelude()
  for _, cls in ipairs(jest_test_suites) do
    if not filter or cls.__name:match(filter) then
      local test_object = cls(cls.__name, cls.__jest_tests)
      local failed_tests, tests_ran = test_object:run_tests(logger)
      total_failure_count = total_failure_count + failed_tests
      total_test_count = total_test_count + tests_ran
    end
  end
  logger.finale(total_failure_count, total_test_count)
  return total_failure_count, total_test_count
end

return {
  describe = describe,
  it = it,
  test = test,
  expect = expect,
  beforeEach = beforeEach,
  afterEach = afterEach,
  run_jest_tests = run_jest_tests,
  jest_test_suites = jest_test_suites,
  jestMatchers = jestMatchers,
}

