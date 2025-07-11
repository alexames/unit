-- mock.lua
-- Mock object for call count and argument validation
--
-- @module unit.mock

local llx = require 'llx'
local class = llx.class

--- A mock function object.
-- Tracks call count, allows expectation of arguments and return values.
-- Example usage:
--   local mock <close> = Mock()
--   mock:call_count(Equals(1)):call_spec{
--     CallSpec{expected_args={Equals(42)}, return_values={"ok"}}
--   }
--   mock(42)
--   -- automatically checks call count at close
Mock = class 'Mock' {
  --- Constructor
  __init = function(self)
    self._call_spec = nil               -- List of CallSpec tables
    self._call_count = 0                -- Number of times mock was called
    self._call_count_expectation = nil  -- Matcher to validate call count
  end;

  --- Define expected behavior of each call
  -- @param call_list A list of CallSpec tables
  call_spec = function(self, call_list)
    self._call_spec = call_list
    return self
  end;

  --- Set expected number of calls
  -- @param expectation A matcher, e.g. Equals(2)
  call_count = function(self, expectation)
    self._call_count_expectation = expectation
    return self
  end;

  --- Called when the mock is invoked.
  -- Validates arguments and returns expected values if provided.
  __call = function(self, ...)
    self._call_count = self._call_count + 1
    local current_call_spec = self._call_spec and self._call_spec[self._call_count]
    if current_call_spec then
      local expected_args = current_call_spec.expected_args
      if expected_args then
        local arguments = {...}
        for i, predicate in ipairs(expected_args) do
          EXPECT_THAT(arguments[i], predicate, 'argument #' .. i)
        end
      end
      local return_values = current_call_spec.return_values
      if return_values then
        return table.unpack(return_values)
      end
    end
  end;

  --- Finalization method.
  -- Validates that call count met expectations.
  __close = function(self)
    local expectation = self._call_count_expectation
    if expectation then
      EXPECT_THAT(self._call_count, expectation, 'call count')
    end
  end;
}

return {
  Mock = Mock,
}
