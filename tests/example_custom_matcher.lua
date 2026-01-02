-- Example: Adding a custom matcher
local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

-- Example: Create a custom matcher that checks if a number is even
local function IsEven()
  return function(actual)
    return {
      pass = type(actual) == 'number' and actual % 2 == 0,
      actual = tostring(actual),
      positive_message = 'be even',
      negative_message = 'be not even',
      expected = 'even number'
    }
  end
end

-- Register the custom matcher
unit.matchers.beEven = function() return IsEven() end

-- Now you can use it in tests!
describe('CustomMatcherExample', function()
  it('should pass when a number is even', function()
    expect(2).to.beEven()
    expect(4).to.beEven()
    expect(0).to.beEven()
  end)

  it('should fail when a number is not even', function()
    local success = pcall(function()
      expect(1).to.beEven()
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('should work with toNot', function()
    expect(1).toNot.beEven()
    expect(3).toNot.beEven()
  end)
end)

run_unit_tests()

