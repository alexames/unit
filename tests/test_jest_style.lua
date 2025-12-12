local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

-- Shared test data
local test_boolean = true
local test_integer = 100
local test_string = 'Hello, world!'

describe('ExpectationTest', function()
  it('should pass when comparing nil to nil', function()
    expect(nil).to.beEqualTo(nil)
  end)

  it('should pass when comparing boolean true to true', function()
    expect(true).to.beEqualTo(true)
    expect(test_boolean).to.beEqualTo(true)
  end)

  it('should pass when comparing boolean false to false', function()
    expect(false).to.beEqualTo(false)
  end)

  it('should pass when comparing equal numbers', function()
    expect(100).to.beEqualTo(100)
    expect(100).to.beEqualTo(test_integer)
  end)

  it('should pass when comparing equal strings', function()
    expect('Hello, world!').to.beEqualTo('Hello, world!')
    expect('Hello, world!').to.beEqualTo(test_string)
  end)

  it('should fail when comparing nil to a non-nil value', function()
    expect(function()
      expect(nil).to.beEqualTo(1)
    end).to.throw()
  end)

  it('should fail when comparing different boolean values', function()
    expect(function()
      expect(true).to.beEqualTo(false)
    end).to.throw()
  end)

  it('should fail when comparing different numbers', function()
    expect(function()
      expect(100).to.beEqualTo(0)
    end).to.throw()
  end)

  it('should fail when comparing different strings', function()
    expect(function()
      expect('Hello, world!').to.beEqualTo('Goodbye, world!')
    end).to.throw()
  end)

  it('should pass when comparing nil to a non-nil value with not', function()
    expect(nil).toNot.beEqualTo(1)
  end)

  it('should pass when comparing different boolean values with not', function()
    expect(true).toNot.beEqualTo(false)
    expect(false).toNot.beEqualTo(true)
    expect(test_boolean).toNot.beEqualTo(false)
  end)

  it('should pass when comparing different numbers with not', function()
    expect(0).toNot.beEqualTo(100)
    expect(0).toNot.beEqualTo(test_integer)
  end)

  it('should pass when comparing different strings with not', function()
    expect('Goodbyte, world!').toNot.beEqualTo('Hello, world!')
    expect('Goodbyte, world!').toNot.beEqualTo(test_string)
  end)

  it('should fail when comparing nil to nil with not', function()
    expect(function()
      expect(nil).toNot.beEqualTo(nil)
    end).to.throw()
  end)

  it('should fail when comparing equal boolean values with not', function()
    expect(function()
      expect(true).toNot.beEqualTo(true)
    end).to.throw()
  end)

  it('should fail when comparing equal numbers with not', function()
    expect(function()
      expect(100).toNot.beEqualTo(100)
    end).to.throw()
  end)

  it('should fail when comparing equal strings with not', function()
    expect(function()
      expect('Hello, world!').toNot.beEqualTo('Hello, world!')
    end).to.throw()
  end)

  it('should pass when comparing true to true', function()
    expect(true).to.beEqualTo(true)
  end)

  it('should fail when comparing false to true', function()
    expect(function()
      expect(false).toBe(true)
    end).to.throw()
  end)

  it('should fail when comparing a number to true', function()
    expect(function()
      expect(1).toBe(true)
    end).to.throw()
  end)

  it('should pass when comparing false to false', function()
    expect(false).to.beEqualTo(false)
  end)

  it('should fail when comparing true to false', function()
    expect(function()
      expect(true).to.beEqualTo(false)
    end).to.throw()
  end)

  it('should fail when comparing nil to false', function()
    expect(function()
      expect(nil).toBe(false)
    end).to.throw()
  end)

  it('should pass when checking that true is truthy', function()
    expect(true).to.beTruthy()
  end)

  it('should pass when checking that a positive number is truthy', function()
    expect(1).to.beTruthy()
  end)

  it('should fail when checking that false is truthy', function()
    expect(function()
      expect(false).to.beTruthy()
    end).to.throw()
  end)

  it('should fail when checking that nil is truthy', function()
    expect(function()
      expect(nil).to.beTruthy()
    end).to.throw()
  end)

  it('should pass when checking that false is falsy', function()
    expect(false).to.beFalsy()
  end)

  it('should pass when checking that nil is falsy', function()
    expect(nil).to.beFalsy()
  end)

  it('should fail when checking that true is falsy', function()
    expect(function()
      expect(true).to.beFalsy()
    end).to.throw()
  end)

  it('should fail when checking that a positive number is falsy', function()
    expect(function()
      expect(1).to.beFalsy()
    end).to.throw()
  end)

  it('should pass when a function throws an error with matching message', function()
    expect(function()
      error('error!')
    end).to.throw('error!')
  end)

  it('should pass when a function throws an error without checking message', function()
    expect(function()
      error('error!')
    end).to.throw()
  end)

  it('should fail when a function does not throw an error', function()
    local successful, exception = pcall(function()
      expect(function() end).to.throw()
    end)
    expect(successful).to.beEqualTo(false)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    expect(exception).to.match(EndsWith('expected function to raise error'))
  end)

  it('should fail when a function throws an error with a different message', function()
    local successful, exception = pcall(function()
      expect(function()
        error('actual error message!')
      end).to.throw('expected error message!')
    end)
    expect(successful).to.beEqualTo(false)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    expect(exception).to.match(EndsWith([[
expected 
  actual error message!
to be equal to
  expected error message!]]))
  end)
end)

describe('NumericAssertionTests', function()
  it('should pass when a number is less than another', function()
    expect(5).to.beLessThan(10)
    expect(-1).to.beLessThan(0)
  end)

  it('should pass when a number is less than or equal to another', function()
    expect(5).to.beLessThanOrEqual(10)
    expect(10).to.beLessThanOrEqual(10)
  end)

  it('should pass when a number is greater than another', function()
    expect(10).to.beGreaterThan(5)
    expect(0).to.beGreaterThan(-1)
  end)

  it('should pass when a number is greater than or equal to another', function()
    expect(10).to.beGreaterThanOrEqual(5)
    expect(10).to.beGreaterThanOrEqual(10)
  end)

  it('should pass when a number is within epsilon of another', function()
    expect(1.0).to.beNear(1.001, 0.01)
    expect(100.0).to.beNear(100.005, 0.01)
  end)

  it('should fail when a number is not within epsilon of another', function()
    local success = pcall(function()
      expect(1.0).to.beNear(2.0, 0.1)
    end)
    expect(success).to.beEqualTo(false)
  end)
end)

describe('NilAssertionTests', function()
  it('should pass when checking that nil is nil', function()
    expect(nil).to.beNil()
  end)

  it('should pass when checking that an undefined variable is nil', function()
    local x
    expect(x).to.beNil()
  end)

  it('should fail when checking that a number is nil', function()
    local success = pcall(function()
      expect(5).to.beNil()
    end)
    expect(success).to.beEqualTo(false)
  end)

  it('should pass when checking that a number is not nil', function()
    expect(5).toNot.beNil()
    expect(0).toNot.beNil()
  end)

  it('should pass when checking that false is not nil', function()
    expect(false).toNot.beNil()
  end)

  it('should pass when checking that an empty string is not nil', function()
    expect("").toNot.beNil()
  end)

  it('should fail when checking that nil is not nil', function()
    local success = pcall(function()
      expect(nil).toNot.beNil()
    end)
    expect(success).to.beEqualTo(false)
  end)
end)

describe('StringAssertionTests', function()
  it('should pass when a string contains a substring', function()
    expect("hello world").to.contain("world")
    expect("test").to.contain("es")
  end)

  it('should fail when a string does not contain a substring', function()
    local success = pcall(function()
      expect("hello").to.contain("xyz")
    end)
    expect(success).to.beEqualTo(false)
  end)

  it('should pass when a string matches a pattern', function()
    expect("hello123").to.matchPattern("%d+")
    expect("test@example.com").to.matchPattern("@")
  end)

  it('should fail when a string does not match a pattern', function()
    local success = pcall(function()
      expect("hello").to.matchPattern("%d+")
    end)
    expect(success).to.beEqualTo(false)
  end)
end)

describe('CollectionAssertionTests', function()
  it('should pass when checking that an empty table is empty', function()
    expect({}).to.beEmpty()
  end)

  it('should pass when checking that an empty string is empty', function()
    expect("").to.beEmpty()
  end)

  it('should fail when checking that a non-empty table is empty', function()
    local success = pcall(function()
      expect({1, 2, 3}).to.beEmpty()
    end)
    expect(success).to.beEqualTo(false)
  end)

  it('should pass when checking that a table has the correct size', function()
    expect({1, 2, 3}).to.haveSize(3)
    expect({a=1, b=2}).to.haveSize(2)
  end)

  it('should fail when checking that a table has the wrong size', function()
    local success = pcall(function()
      expect({1, 2}).to.haveSize(5)
    end)
    expect(success).to.beEqualTo(false)
  end)
end)

describe('ErrorAssertionTests', function()
  it('should pass when a function throws an error', function()
    expect(function()
      error("test error")
    end).to.throw()
  end)

  it('should fail when a function does not throw an error', function()
    local success = pcall(function()
      expect(function()
        return 42
      end).to.throw()
    end)
    expect(success).to.beEqualTo(false)
  end)

  it('should pass when a function does not throw an error with not', function()
    expect(function()
      return 42
    end).toNot.throw()
  end)

  it('should fail when a function throws an error with not', function()
    local success = pcall(function()
      expect(function()
        error("oops")
      end).toNot.throw()
    end)
    expect(success).to.beEqualTo(false)
  end)
end)

describe('NumericMatcherTests', function()
  it('should pass when a number is near another within epsilon', function()
    expect(1.0).to.match(Near(1.001, 0.01))
    expect(100.0).to.match(Near(100.005, 0.01))
  end)

  it('should pass when checking that a positive integer is positive', function()
    expect(5).to.match(IsPositive())
  end)

  it('should pass when checking that a positive float is positive', function()
    expect(0.1).to.match(IsPositive())
  end)

  it('should pass when checking that a negative integer is negative', function()
    expect(-5).to.match(IsNegative())
  end)

  it('should pass when checking that a negative float is negative', function()
    expect(-0.1).to.match(IsNegative())
  end)

  it('should pass when checking that a number between min and max is between them', function()
    expect(5).to.match(IsBetween(1, 10))
  end)

  it('should pass when checking that the minimum value is between min and max', function()
    expect(1).to.match(IsBetween(1, 10))
  end)

  it('should pass when checking that the maximum value is between min and max', function()
    expect(10).to.match(IsBetween(1, 10))
  end)

  it('should pass when checking that NaN is NaN', function()
    local nan = 0/0
    expect(nan).to.match(IsNaN())
  end)
end)

describe('StringMatcherTests', function()
  it('should pass when checking that a string contains a substring', function()
    expect("hello world").to.match(Contains("world"))
    expect("test").to.match(Contains("es"))
  end)

  it('should pass when checking that a string matches a pattern', function()
    expect("hello123").to.match(Matches("%d+"))
    expect("test@example.com").to.match(Matches("@"))
  end)

  it('should pass when checking that an empty string is empty', function()
    expect("").to.match(IsEmpty())
  end)

  it('should pass when checking that a string has the correct length', function()
    expect("hello").to.match(HasLength(5))
    expect("").to.match(HasLength(0))
  end)
end)

describe('CollectionMatcherTests', function()
  it('should pass when checking that an empty table is empty', function()
    expect({}).to.match(IsEmpty())
  end)

  it('should pass when checking that a table has the correct size', function()
    expect({1, 2, 3}).to.match(HasSize(3))
    expect({a=1, b=2}).to.match(HasSize(2))
  end)

  it('should pass when checking that a table contains a numeric element', function()
    expect({1, 2, 3}).to.match(ContainsElement(2))
  end)

  it('should pass when checking that a table contains a string element', function()
    expect({"a", "b", "c"}).to.match(ContainsElement("b"))
  end)
end)

describe('CompositeMatcherTests', function()
  it('should pass when all matchers in AllOf match', function()
    expect(5).to.match(AllOf(GreaterThan(0), LessThan(10)))
  end)

  it('should fail when one matcher in AllOf does not match', function()
    local success = pcall(function()
      expect(15).to.match(AllOf(GreaterThan(0), LessThan(10)))
    end)
    expect(success).to.beEqualTo(false)
  end)

  it('should pass when the first matcher in AnyOf matches', function()
    expect(5).to.match(AnyOf(Equals(5), Equals(10)))
  end)

  it('should pass when the second matcher in AnyOf matches', function()
    expect(10).to.match(AnyOf(Equals(5), Equals(10)))
  end)

  it('should fail when no matchers in AnyOf match', function()
    local success = pcall(function()
      expect(7).to.match(AnyOf(Equals(5), Equals(10)))
    end)
    expect(success).to.beEqualTo(false)
  end)
end)

-- Error level testing - verify errors point to correct location
describe('ErrorLevelTests', function()
  it('should report errors at the correct line for toBe', function()
    local success, err = pcall(function()
      expect(1).to.beEqualTo(2)  -- Error should point to THIS line
    end)
    expect(success).to.beEqualTo(false)
    -- Error message should contain this file and line number
    expect(type(err)).to.beEqualTo('string')
  end)

  it('should report errors at the correct line for toBeLessThan', function()
    local success, err = pcall(function()
      expect(10).to.beLessThan(5)  -- Error should point to THIS line
    end)
    expect(success).to.beEqualTo(false)
    expect(type(err)).to.beEqualTo('string')
  end)

  it('should report errors at the correct line for toBeNear', function()
    local success, err = pcall(function()
      expect(1.0).to.beNear(10.0, 0.1)  -- Error should point to THIS line
    end)
    expect(success).to.beEqualTo(false)
    expect(type(err)).to.beEqualTo('string')
  end)
end)

run_unit_tests()

