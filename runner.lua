-- runner.lua
-- Test registration and execution logic
--
-- @module unit.runner

local llx = require 'llx'
local test = require 'unit.test'
local test_logger = require 'unit.test_logger'

local class = llx.class

-- This is a list of classes that have been registered with unit.
local global_test_suites = llx.Table{}

--- Registers a test class.
-- Usage:
--   test_class 'MySuite' {
--     ['test_name' | test] = function() ... end
--   }
-- @param name The name of the test class
-- @return A decorator that registers the test class
local function test_class(name)
  return function(class_definition)
    -- Extend from unit.Test and register the class
    local cls = class(name):extends(test.Test)(class_definition)
    global_test_suites:insert(cls)
  end
end

--- Executes all registered test classes.
-- @param[opt] filter A string to match against test class names
-- @param[opt] logger An optional logger object to capture output
local function run_unit_tests(filter, logger)
  local test_suites = global_test_suites
  logger = logger or test_logger.TestLogger()
  local total_failure_count = 0
  local total_test_count = 0
  local failure_list = llx.Table()

  logger.prelude()
  for _, cls in ipairs(test_suites) do
    if not filter or cls.__name:match(filter) then
      local test_object = cls()
      local failed_tests, tests_ran = test_object:run_tests(logger)
      total_failure_count = total_failure_count + failed_tests
      total_test_count = total_test_count + tests_ran
    end
  end
  logger.finale(total_failure_count, total_test_count)
end

return {
  test_class = test_class,
  run_unit_tests = run_unit_tests,
}
