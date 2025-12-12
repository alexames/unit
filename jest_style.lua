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

--- Creates an expect object with matcher methods
-- @param actual The actual value to test
-- @return An object with matcher methods
local function expect(actual)
  local expect_obj = {
    _actual = actual,
    _negated = false,
  }

  -- Helper to create a matcher method
  local function create_matcher(matcher_func, ...)
    return function(...)
      local args = {...}
      local matcher = matcher_func(...)
      
      if expect_obj._negated then
        matcher = matchers.Not(matcher)
        expect_obj._negated = false
      end
      
      expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
    end
  end

  -- Basic equality
  expect_obj.toBe = create_matcher(matchers.Equals)
  expect_obj.toEqual = create_matcher(matchers.Equals)  -- Alias for toBe

  -- Comparison matchers
  expect_obj.toBeGreaterThan = create_matcher(matchers.GreaterThan)
  expect_obj.toBeGreaterThanOrEqual = create_matcher(matchers.GreaterThanOrEqual)
  expect_obj.toBeLessThan = create_matcher(matchers.LessThan)
  expect_obj.toBeLessThanOrEqual = create_matcher(matchers.LessThanOrEqual)

  -- String matchers
  expect_obj.toContain = create_matcher(matchers.Contains)
  expect_obj.toMatch = create_matcher(matchers.Matches)
  expect_obj.toStartWith = create_matcher(matchers.StartsWith)
  expect_obj.toEndWith = create_matcher(matchers.EndsWith)
  expect_obj.toHaveLength = create_matcher(matchers.HasLength)

  -- Collection matchers
  expect_obj.toBeEmpty = function()
    local matcher = matchers.IsEmpty()
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end
  expect_obj.toHaveSize = create_matcher(matchers.HasSize)
  expect_obj.toContainElement = create_matcher(matchers.ContainsElement)

  -- Type and value matchers
  expect_obj.toBeNil = function()
    local matcher = matchers.Equals(nil)
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end
  expect_obj.toBeTruthy = function()
    local matcher = function(actual)
      return truthy(actual),
             tostring(actual),
             'be truthy',
             'be not truthy',
             'truthy value'
    end
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end
  expect_obj.toBeFalsy = function()
    local matcher = function(actual)
      return falsey(actual),
             tostring(actual),
             'be falsy',
             'be not falsy',
             'falsy value'
    end
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end

  -- Numeric matchers
  expect_obj.toBeNear = create_matcher(matchers.Near)
  expect_obj.toBePositive = function()
    local matcher = matchers.IsPositive()
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end
  expect_obj.toBeNegative = function()
    local matcher = matchers.IsNegative()
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end
  expect_obj.toBeBetween = create_matcher(matchers.IsBetween)
  expect_obj.toBeNaN = function()
    local matcher = matchers.IsNaN()
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end

  -- Type checking
  expect_obj.toBeOfType = create_matcher(matchers.IsOfType)

  -- Error matcher
  expect_obj.toThrow = function(expected)
    local level = 3
    if type(expect_obj._actual) ~= 'function' then
      error('toThrow() expects a function, got ' .. type(expect_obj._actual), level)
    end
    local should_throw = not expect_obj._negated
    expect_obj._negated = false
    
    local successful, exception = pcall(expect_obj._actual)
    
    if should_throw then
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
    else
      -- Expect function NOT to throw
      if not successful then
        error('expected function not to raise error, but got: ' .. tostring(exception), level)
      end
    end
  end

  -- Composite matchers
  expect_obj.toSatisfy = function(...)
    local matchers_list = {...}
    local matcher = matchers.AllOf(...)
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end
  expect_obj.toSatisfyAny = function(...)
    local matchers_list = {...}
    local matcher = matchers.AnyOf(...)
    if expect_obj._negated then
      matcher = matchers.Not(matcher)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end

  -- Custom matcher support - allows passing any matcher function
  expect_obj.toMatchMatcher = function(matcher_func)
    if expect_obj._negated then
      matcher_func = matchers.Not(matcher_func)
      expect_obj._negated = false
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher_func, 3)
  end

  -- Negation support
  local not_proxy = {}
  setmetatable(not_proxy, {
    __index = function(_, key)
      expect_obj._negated = true
      local method = expect_obj[key]
      if type(method) == 'function' then
        return method
      end
      return nil
    end
  })
  expect_obj.not = not_proxy

  return expect_obj
end

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
}

