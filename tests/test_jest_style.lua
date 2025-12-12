local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

-- Shared test data
local test_boolean = true
local test_integer = 100
local test_string = 'Hello, world!'

describe('ExpectationTest', function()
  it('should pass when comparing nil to nil', function()
    expect(nil).toBe(nil)
  end)

  it('should pass when comparing boolean true to true', function()
    expect(true).toBe(true)
    expect(test_boolean).toBe(true)
  end)

  it('should pass when comparing boolean false to false', function()
    expect(false).toBe(false)
  end)

  it('should pass when comparing equal numbers', function()
    expect(100).toBe(100)
    expect(100).toBe(test_integer)
  end)

  it('should pass when comparing equal strings', function()
    expect('Hello, world!').toBe('Hello, world!')
    expect('Hello, world!').toBe(test_string)
  end)

  it('should fail when comparing nil to a non-nil value', function()
    expect(function()
      expect(nil).toBe(1)
    end).toThrow()
  end)

  it('should fail when comparing different boolean values', function()
    expect(function()
      expect(true).toBe(false)
    end).toThrow()
  end)

  it('should fail when comparing different numbers', function()
    expect(function()
      expect(100).toBe(0)
    end).toThrow()
  end)

  it('should fail when comparing different strings', function()
    expect(function()
      expect('Hello, world!').toBe('Goodbye, world!')
    end).toThrow()
  end)

  it('should pass when comparing nil to a non-nil value with not', function()
    expect(nil).not.toBe(1)
  end)

  it('should pass when comparing different boolean values with not', function()
    expect(true).not.toBe(false)
    expect(false).not.toBe(true)
    expect(test_boolean).not.toBe(false)
  end)

  it('should pass when comparing different numbers with not', function()
    expect(0).not.toBe(100)
    expect(0).not.toBe(test_integer)
  end)

  it('should pass when comparing different strings with not', function()
    expect('Goodbyte, world!').not.toBe('Hello, world!')
    expect('Goodbyte, world!').not.toBe(test_string)
  end)

  it('should fail when comparing nil to nil with not', function()
    expect(function()
      expect(nil).not.toBe(nil)
    end).toThrow()
  end)

  it('should fail when comparing equal boolean values with not', function()
    expect(function()
      expect(true).not.toBe(true)
    end).toThrow()
  end)

  it('should fail when comparing equal numbers with not', function()
    expect(function()
      expect(100).not.toBe(100)
    end).toThrow()
  end)

  it('should fail when comparing equal strings with not', function()
    expect(function()
      expect('Hello, world!').not.toBe('Hello, world!')
    end).toThrow()
  end)

  it('should pass when comparing true to true', function()
    expect(true).toBe(true)
  end)

  it('should fail when comparing false to true', function()
    expect(function()
      expect(false).toBe(true)
    end).toThrow()
  end)

  it('should fail when comparing a number to true', function()
    expect(function()
      expect(1).toBe(true)
    end).toThrow()
  end)

  it('should pass when comparing false to false', function()
    expect(false).toBe(false)
  end)

  it('should fail when comparing true to false', function()
    expect(function()
      expect(true).toBe(false)
    end).toThrow()
  end)

  it('should fail when comparing nil to false', function()
    expect(function()
      expect(nil).toBe(false)
    end).toThrow()
  end)

  it('should pass when checking that true is truthy', function()
    expect(true).toBeTruthy()
  end)

  it('should pass when checking that a positive number is truthy', function()
    expect(1).toBeTruthy()
  end)

  it('should fail when checking that false is truthy', function()
    expect(function()
      expect(false).toBeTruthy()
    end).toThrow()
  end)

  it('should fail when checking that nil is truthy', function()
    expect(function()
      expect(nil).toBeTruthy()
    end).toThrow()
  end)

  it('should pass when checking that false is falsy', function()
    expect(false).toBeFalsy()
  end)

  it('should pass when checking that nil is falsy', function()
    expect(nil).toBeFalsy()
  end)

  it('should fail when checking that true is falsy', function()
    expect(function()
      expect(true).toBeFalsy()
    end).toThrow()
  end)

  it('should fail when checking that a positive number is falsy', function()
    expect(function()
      expect(1).toBeFalsy()
    end).toThrow()
  end)

  it('should pass when a function throws an error with matching message', function()
    expect(function()
      error('error!')
    end).toThrow('error!')
  end)

  it('should pass when a function throws an error without checking message', function()
    expect(function()
      error('error!')
    end).toThrow()
  end)

  it('should fail when a function does not throw an error', function()
    local successful, exception = pcall(function()
      expect(function() end).toThrow()
    end)
    expect(successful).toBe(false)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    expect(exception).toMatchMatcher(EndsWith('expected function to raise error'))
  end)

  it('should fail when a function throws an error with a different message', function()
    local successful, exception = pcall(function()
      expect(function()
        error('actual error message!')
      end).toThrow('expected error message!')
    end)
    expect(successful).toBe(false)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    expect(exception).toMatchMatcher(EndsWith([[
expected 
  actual error message!
to be equal to
  expected error message!]]))
  end)
end)

describe('NumericAssertionTests', function()
  it('should pass when a number is less than another', function()
    expect(5).toBeLessThan(10)
    expect(-1).toBeLessThan(0)
  end)

  it('should pass when a number is less than or equal to another', function()
    expect(5).toBeLessThanOrEqual(10)
    expect(10).toBeLessThanOrEqual(10)
  end)

  it('should pass when a number is greater than another', function()
    expect(10).toBeGreaterThan(5)
    expect(0).toBeGreaterThan(-1)
  end)

  it('should pass when a number is greater than or equal to another', function()
    expect(10).toBeGreaterThanOrEqual(5)
    expect(10).toBeGreaterThanOrEqual(10)
  end)

  it('should pass when a number is within epsilon of another', function()
    expect(1.0).toBeNear(1.001, 0.01)
    expect(100.0).toBeNear(100.005, 0.01)
  end)

  it('should fail when a number is not within epsilon of another', function()
    local success = pcall(function()
      expect(1.0).toBeNear(2.0, 0.1)
    end)
    expect(success).toBe(false)
  end)
end)

describe('NilAssertionTests', function()
  it('should pass when checking that nil is nil', function()
    expect(nil).toBeNil()
  end)

  it('should pass when checking that an undefined variable is nil', function()
    local x
    expect(x).toBeNil()
  end)

  it('should fail when checking that a number is nil', function()
    local success = pcall(function()
      expect(5).toBeNil()
    end)
    expect(success).toBe(false)
  end)

  it('should pass when checking that a number is not nil', function()
    expect(5).not.toBeNil()
    expect(0).not.toBeNil()
  end)

  it('should pass when checking that false is not nil', function()
    expect(false).not.toBeNil()
  end)

  it('should pass when checking that an empty string is not nil', function()
    expect("").not.toBeNil()
  end)

  it('should fail when checking that nil is not nil', function()
    local success = pcall(function()
      expect(nil).not.toBeNil()
    end)
    expect(success).toBe(false)
  end)
end)

describe('StringAssertionTests', function()
  it('should pass when a string contains a substring', function()
    expect("hello world").toContain("world")
    expect("test").toContain("es")
  end)

  it('should fail when a string does not contain a substring', function()
    local success = pcall(function()
      expect("hello").toContain("xyz")
    end)
    expect(success).toBe(false)
  end)

  it('should pass when a string matches a pattern', function()
    expect("hello123").toMatch("%d+")
    expect("test@example.com").toMatch("@")
  end)

  it('should fail when a string does not match a pattern', function()
    local success = pcall(function()
      expect("hello").toMatch("%d+")
    end)
    expect(success).toBe(false)
  end)
end)

describe('CollectionAssertionTests', function()
  it('should pass when checking that an empty table is empty', function()
    expect({}).toBeEmpty()
  end)

  it('should pass when checking that an empty string is empty', function()
    expect("").toBeEmpty()
  end)

  it('should fail when checking that a non-empty table is empty', function()
    local success = pcall(function()
      expect({1, 2, 3}).toBeEmpty()
    end)
    expect(success).toBe(false)
  end)

  it('should pass when checking that a table has the correct size', function()
    expect({1, 2, 3}).toHaveSize(3)
    expect({a=1, b=2}).toHaveSize(2)
  end)

  it('should fail when checking that a table has the wrong size', function()
    local success = pcall(function()
      expect({1, 2}).toHaveSize(5)
    end)
    expect(success).toBe(false)
  end)
end)

describe('ErrorAssertionTests', function()
  it('should pass when a function throws an error', function()
    expect(function()
      error("test error")
    end).toThrow()
  end)

  it('should fail when a function does not throw an error', function()
    local success = pcall(function()
      expect(function()
        return 42
      end).toThrow()
    end)
    expect(success).toBe(false)
  end)

  it('should pass when a function does not throw an error with not', function()
    expect(function()
      return 42
    end).not.toThrow()
  end)

  it('should fail when a function throws an error with not', function()
    local success = pcall(function()
      expect(function()
        error("oops")
      end).not.toThrow()
    end)
    expect(success).toBe(false)
  end)
end)

describe('NumericMatcherTests', function()
  it('should pass when a number is near another within epsilon', function()
    expect(1.0).toMatchMatcher(Near(1.001, 0.01))
    expect(100.0).toMatchMatcher(Near(100.005, 0.01))
  end)

  it('should pass when checking that a positive integer is positive', function()
    expect(5).toMatchMatcher(IsPositive())
  end)

  it('should pass when checking that a positive float is positive', function()
    expect(0.1).toMatchMatcher(IsPositive())
  end)

  it('should pass when checking that a negative integer is negative', function()
    expect(-5).toMatchMatcher(IsNegative())
  end)

  it('should pass when checking that a negative float is negative', function()
    expect(-0.1).toMatchMatcher(IsNegative())
  end)

  it('should pass when checking that a number between min and max is between them', function()
    expect(5).toMatchMatcher(IsBetween(1, 10))
  end)

  it('should pass when checking that the minimum value is between min and max', function()
    expect(1).toMatchMatcher(IsBetween(1, 10))
  end)

  it('should pass when checking that the maximum value is between min and max', function()
    expect(10).toMatchMatcher(IsBetween(1, 10))
  end)

  it('should pass when checking that NaN is NaN', function()
    local nan = 0/0
    expect(nan).toMatchMatcher(IsNaN())
  end)
end)

describe('StringMatcherTests', function()
  it('should pass when checking that a string contains a substring', function()
    expect("hello world").toMatchMatcher(Contains("world"))
    expect("test").toMatchMatcher(Contains("es"))
  end)

  it('should pass when checking that a string matches a pattern', function()
    expect("hello123").toMatchMatcher(Matches("%d+"))
    expect("test@example.com").toMatchMatcher(Matches("@"))
  end)

  it('should pass when checking that an empty string is empty', function()
    expect("").toMatchMatcher(IsEmpty())
  end)

  it('should pass when checking that a string has the correct length', function()
    expect("hello").toMatchMatcher(HasLength(5))
    expect("").toMatchMatcher(HasLength(0))
  end)
end)

describe('CollectionMatcherTests', function()
  it('should pass when checking that an empty table is empty', function()
    expect({}).toMatchMatcher(IsEmpty())
  end)

  it('should pass when checking that a table has the correct size', function()
    expect({1, 2, 3}).toMatchMatcher(HasSize(3))
    expect({a=1, b=2}).toMatchMatcher(HasSize(2))
  end)

  it('should pass when checking that a table contains a numeric element', function()
    expect({1, 2, 3}).toMatchMatcher(ContainsElement(2))
  end)

  it('should pass when checking that a table contains a string element', function()
    expect({"a", "b", "c"}).toMatchMatcher(ContainsElement("b"))
  end)
end)

describe('CompositeMatcherTests', function()
  it('should pass when all matchers in AllOf match', function()
    expect(5).toMatchMatcher(AllOf(GreaterThan(0), LessThan(10)))
  end)

  it('should fail when one matcher in AllOf does not match', function()
    local success = pcall(function()
      expect(15).toMatchMatcher(AllOf(GreaterThan(0), LessThan(10)))
    end)
    expect(success).toBe(false)
  end)

  it('should pass when the first matcher in AnyOf matches', function()
    expect(5).toMatchMatcher(AnyOf(Equals(5), Equals(10)))
  end)

  it('should pass when the second matcher in AnyOf matches', function()
    expect(10).toMatchMatcher(AnyOf(Equals(5), Equals(10)))
  end)

  it('should fail when no matchers in AnyOf match', function()
    local success = pcall(function()
      expect(7).toMatchMatcher(AnyOf(Equals(5), Equals(10)))
    end)
    expect(success).toBe(false)
  end)
end)

-- Error level testing - verify errors point to correct location
describe('ErrorLevelTests', function()
  it('should report errors at the correct line for toBe', function()
    local success, err = pcall(function()
      expect(1).toBe(2)  -- Error should point to THIS line
    end)
    expect(success).toBe(false)
    -- Error message should contain this file and line number
    expect(type(err)).toBe('string')
  end)

  it('should report errors at the correct line for toBeLessThan', function()
    local success, err = pcall(function()
      expect(10).toBeLessThan(5)  -- Error should point to THIS line
    end)
    expect(success).toBe(false)
    expect(type(err)).toBe('string')
  end)

  it('should report errors at the correct line for toBeNear', function()
    local success, err = pcall(function()
      expect(1.0).toBeNear(10.0, 0.1)  -- Error should point to THIS line
    end)
    expect(success).toBe(false)
    expect(type(err)).toBe('string')
  end)
end)

run_unit_tests()

