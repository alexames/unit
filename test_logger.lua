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

-- Module-level variable to store the current JestLogger instance
local current_jest_logger = nil

--- Jest-style logger for displaying test results.
JestLogger = class 'JestLogger' {
  __init = function(self)
    self.test_suites = {}
    self.current_suite = nil
    self.total_passed = 0
    self.total_failed = 0
    self.total_tests = 0
    current_jest_logger = self
  end;

  --- Called once before any tests run.
  prelude = function() end;

  --- Prints the beginning of a test class.
  -- @param test_suite The test class object
  class_preamble = function(test_suite)
    if not current_jest_logger then
      error('JestLogger instance not found')
    end
    current_jest_logger.current_suite = {
      name = test_suite:name(),
      tests = {},
      passed = 0,
      failed = 0,
    }
    table.insert(current_jest_logger.test_suites, current_jest_logger.current_suite)
  end;

  --- Prints the beginning of a single test.
  test_begin = function(test_suite, test_name)
    -- Jest doesn't print test begin, we'll print it in test_end
  end;

  --- Prints the result of a test case.
  test_end = function(test_suite, test_name, successful, err)
    if not current_jest_logger then
      error('JestLogger instance not found')
    end
    local test_name_str = table.concat(test_name, ' ')
    local test_info = {
      name = test_name_str,
      passed = successful,
      error = err,
    }
    table.insert(current_jest_logger.current_suite.tests, test_info)
    
    if successful then
      current_jest_logger.current_suite.passed = current_jest_logger.current_suite.passed + 1
      current_jest_logger.total_passed = current_jest_logger.total_passed + 1
    else
      current_jest_logger.current_suite.failed = current_jest_logger.current_suite.failed + 1
      current_jest_logger.total_failed = current_jest_logger.total_failed + 1
    end
    current_jest_logger.total_tests = current_jest_logger.total_tests + 1
  end;

  --- Prints summary of the test class.
  -- @param test_suite The test class
  -- @param failure_count Number of failing tests
  class_conclusion = function(test_suite, failure_count)
    -- We'll print this in finale
  end;

  --- Prints final global test results.
  finale = function(total_failure_count, total_test_count)
    if not current_jest_logger then
      error('JestLogger instance not found')
    end
    
    -- Print each test suite
    for _, suite in ipairs(current_jest_logger.test_suites) do
      local suite_status = suite.failed > 0 and 'FAIL' or 'PASS'
      local suite_color = suite.failed > 0 and red or green
      
      printf('%s%s%s  %s%s', color(suite_color), suite_status, reset(), suite.name, reset())
      
      -- Print each test in the suite
      for _, test in ipairs(suite.tests) do
        if test.passed then
          printf('  %s+%s %s', color(green), reset(), test.name)
        else
          printf('  %s-%s %s', color(red), reset(), test.name)
          -- Print error details
          if test.error then
            local error_lines = {}
            for line in test.error:gmatch('[^\r\n]+') do
              table.insert(error_lines, line)
            end
            -- Print first few lines of error, indented
            for i = 1, math.min(5, #error_lines) do
              printf('    %s', error_lines[i])
            end
            if #error_lines > 5 then
              printf('    ... (%d more lines)', #error_lines - 5)
            end
          end
        end
      end
      print()
    end
    
    -- Print summary
    print()
    local all_passed = total_failure_count == 0
    local summary_color = all_passed and green or red
    
    local suite_count = #current_jest_logger.test_suites
    local passed_suites = 0
    local failed_suites = 0
    for _, suite in ipairs(current_jest_logger.test_suites) do
      if suite.failed == 0 then
        passed_suites = passed_suites + 1
      else
        failed_suites = failed_suites + 1
      end
    end
    
    printf('Test Suites: %s%d %s, %d total',
           color(summary_color),
           all_passed and passed_suites or failed_suites,
           all_passed and 'passed' or 'failed',
           suite_count)
    print()
    
    printf('Tests:       %s%d %s, %d total',
           color(summary_color),
           all_passed and total_test_count or total_failure_count,
           all_passed and 'passed' or 'failed',
           total_test_count)
    print()
    
    if all_passed then
      printf('%s+%s All tests passed!', color(green), reset())
    else
      printf('%s-%s %d test(s) failed', color(red), reset(), total_failure_count)
    end
    print()
  end;
}

return {
  TestLogger = TestLogger,
  JestLogger = JestLogger,
}
