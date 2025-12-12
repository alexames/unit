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
-- @return An object with to and toNot properties
local function expect(actual)
  local expect_obj = {
    _actual = actual,
  }

  -- Helper to create a matcher method that applies a matcher function
  local function create_matcher_method(matcher_creator, ...)
    return function(...)
      local matcher = matcher_creator(...)
      expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
    end
  end

  -- Helper to create a negated matcher method
  local function create_negated_matcher_method(matcher_creator, ...)
    return function(...)
      local matcher = matcher_creator(...)
      expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matcher), 3)
    end
  end

  -- Create matcher methods for 'to'
  local to_methods = {}

  -- Basic equality
  to_methods.beEqualTo = create_matcher_method(matchers.Equals)

  -- Comparison matchers
  to_methods.beGreaterThan = create_matcher_method(matchers.GreaterThan)
  to_methods.beGreaterThanOrEqual = create_matcher_method(matchers.GreaterThanOrEqual)
  to_methods.beLessThan = create_matcher_method(matchers.LessThan)
  to_methods.beLessThanOrEqual = create_matcher_method(matchers.LessThanOrEqual)

  -- String matchers
  to_methods.contain = create_matcher_method(matchers.Contains)
  to_methods.matchPattern = create_matcher_method(matchers.Matches)
  to_methods.startWith = create_matcher_method(matchers.StartsWith)
  to_methods.endWith = create_matcher_method(matchers.EndsWith)
  to_methods.haveLength = create_matcher_method(matchers.HasLength)

  -- Collection matchers
  to_methods.beEmpty = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.IsEmpty(), 3)
  end
  to_methods.haveSize = create_matcher_method(matchers.HasSize)
  to_methods.containElement = create_matcher_method(matchers.ContainsElement)

  -- Type and value matchers
  to_methods.beNil = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.Equals(nil), 3)
  end
  to_methods.beTruthy = function()
    local matcher = function(actual)
      return truthy(actual),
             tostring(actual),
             'be truthy',
             'be not truthy',
             'truthy value'
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end
  to_methods.beFalsy = function()
    local matcher = function(actual)
      return falsey(actual),
             tostring(actual),
             'be falsy',
             'be not falsy',
             'falsy value'
    end
    expects.EXPECT_THAT(expect_obj._actual, matcher, 3)
  end

  -- Numeric matchers
  to_methods.beNear = create_matcher_method(matchers.Near)
  to_methods.bePositive = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.IsPositive(), 3)
  end
  to_methods.beNegative = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.IsNegative(), 3)
  end
  to_methods.beBetween = create_matcher_method(matchers.IsBetween)
  to_methods.beNaN = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.IsNaN(), 3)
  end

  -- Type checking
  to_methods.beOfType = create_matcher_method(matchers.IsOfType)

  -- Error matcher
  to_methods.throw = function(expected)
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

  -- Composite matchers
  to_methods.satisfy = function(...)
    expects.EXPECT_THAT(expect_obj._actual, matchers.AllOf(...), 3)
  end
  to_methods.satisfyAny = function(...)
    expects.EXPECT_THAT(expect_obj._actual, matchers.AnyOf(...), 3)
  end

  -- Custom matcher support - allows passing any matcher function
  to_methods.match = function(matcher_func)
    expects.EXPECT_THAT(expect_obj._actual, matcher_func, 3)
  end

  -- Create toNot methods (negated versions)
  local toNot_methods = {}

  toNot_methods.beEqualTo = create_negated_matcher_method(matchers.Equals)
  toNot_methods.beGreaterThan = create_negated_matcher_method(matchers.GreaterThan)
  toNot_methods.beGreaterThanOrEqual = create_negated_matcher_method(matchers.GreaterThanOrEqual)
  toNot_methods.beLessThan = create_negated_matcher_method(matchers.LessThan)
  toNot_methods.beLessThanOrEqual = create_negated_matcher_method(matchers.LessThanOrEqual)
  toNot_methods.contain = create_negated_matcher_method(matchers.Contains)
  toNot_methods.matchPattern = create_negated_matcher_method(matchers.Matches)
  toNot_methods.startWith = create_negated_matcher_method(matchers.StartsWith)
  toNot_methods.endWith = create_negated_matcher_method(matchers.EndsWith)
  toNot_methods.haveLength = create_negated_matcher_method(matchers.HasLength)
  toNot_methods.beEmpty = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.IsEmpty()), 3)
  end
  toNot_methods.haveSize = create_negated_matcher_method(matchers.HasSize)
  toNot_methods.containElement = create_negated_matcher_method(matchers.ContainsElement)
  toNot_methods.beNil = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.Equals(nil)), 3)
  end
  toNot_methods.beTruthy = function()
    local matcher = function(actual)
      return truthy(actual),
             tostring(actual),
             'be truthy',
             'be not truthy',
             'truthy value'
    end
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matcher), 3)
  end
  toNot_methods.beFalsy = function()
    local matcher = function(actual)
      return falsey(actual),
             tostring(actual),
             'be falsy',
             'be not falsy',
             'falsy value'
    end
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matcher), 3)
  end
  toNot_methods.beNear = create_negated_matcher_method(matchers.Near)
  toNot_methods.bePositive = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.IsPositive()), 3)
  end
  toNot_methods.beNegative = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.IsNegative()), 3)
  end
  toNot_methods.beBetween = create_negated_matcher_method(matchers.IsBetween)
  toNot_methods.beNaN = function()
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.IsNaN()), 3)
  end
  toNot_methods.beOfType = create_negated_matcher_method(matchers.IsOfType)
  toNot_methods.throw = function(expected)
    local level = 3
    if type(expect_obj._actual) ~= 'function' then
      error('throw() expects a function, got ' .. type(expect_obj._actual), level)
    end
    local successful, exception = pcall(expect_obj._actual)
    if not successful then
      error('expected function not to raise error, but got: ' .. tostring(exception), level)
    end
  end
  toNot_methods.satisfy = function(...)
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.AllOf(...)), 3)
  end
  toNot_methods.satisfyAny = function(...)
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matchers.AnyOf(...)), 3)
  end
  toNot_methods.match = function(matcher_func)
    expects.EXPECT_THAT(expect_obj._actual, matchers.Not(matcher_func), 3)
  end

  -- Create proxies
  local to_proxy = {}
  setmetatable(to_proxy, {
    __index = function(_, key)
      return to_methods[key]
    end
  })

  local toNot_proxy = {}
  setmetatable(toNot_proxy, {
    __index = function(_, key)
      return toNot_methods[key]
    end
  })

  expect_obj.to = to_proxy
  expect_obj.toNot = toNot_proxy

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

