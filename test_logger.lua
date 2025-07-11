-- test_logger.lua
-- Console-based test output formatter
--
-- @module unit.test_logger

local llx = require 'llx'
local class = llx.class
local red = llx.debug.red
local green = llx.debug.green
local bright_cyan = llx.debug.bright_cyan
local color = llx.debug.color
local reset = llx.debug.reset
local printf = llx.printf

--- Logger used for displaying test results to stdout.
TestLogger = class 'TestLogger' {
  --- Returns the current test suite name.
  test_suite_name = function(self)
    return self.test_suite.__class_name
  end;

  --- Called once before any tests run.
  prelude = function() end;

  --- Prints the beginning of a test class.
  -- @param test_suite The test class object
  class_preamble = function(test_suite)
    printf('%s[==========]%s Running %s tests from %s%s%s',
            color(green), reset(), #test_suite:tests(), color(bright_cyan),
            test_suite:name(), reset())
  end;

  --- Prints the beginning of a single test.
  test_begin = function(test_suite, test_name)
    printf('%s[ Run      ] %s%s.%s%s',
           color(green), color(bright_cyan), test_suite:name(), table.concat(test_name, '.'), reset())
  end;

  --- Prints the result of a test case.
  test_end = function(test_suite, test_name, successful, err)
    if successful then
      printf('%s[       OK ] %s%s.%s%s',
             color(green), color(bright_cyan), test_suite:name(), table.concat(test_name, '.'), reset())
    else
      printf('%s[  FAILURE ] %s%s.%s%s\n%s',
             color(red), color(bright_cyan), test_suite:name(), table.concat(test_name, '.'), reset(), err)
    end
  end;

  --- Prints summary of the test class.
  -- @param test_suite The test class
  -- @param failure_count Number of failing tests
  class_conclusion = function(test_suite, failure_count)
    if failure_count == 0 then
      printf('%s[==========]%s All %s tests succeeded!',
             color(green), reset(), test_suite:name())
    else
      printf('%s[==========]%s %s / %s failed.',
             color(red), reset(), failure_count, #test_suite:tests())
    end
    print()
  end;

  --- Prints final global test results.
  finale = function(total_failure_count, total_test_count)
    if total_failure_count == 0 then
      printf('%s[==========]%s All tests succeeded!',
             color(green), reset())
    else
      printf('%s[==========]%s %s / %s failed.',
             color(red), reset(), total_failure_count, total_test_count)
    end
  end;
}

return {
  TestLogger = TestLogger,
}
