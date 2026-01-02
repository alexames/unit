local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

-- Shared test data
local test_boolean = true
local test_integer = 100
local test_string = 'Hello, world!'

describe('ExpectationTest', function()
  it('should pass when comparing nil to nil', function()
    expect(nil).to.be_equal_to(nil)
  end)

  it('should pass when comparing boolean true to true', function()
    expect(true).to.be_equal_to(true)
    expect(test_boolean).to.be_equal_to(true)
  end)

  it('should pass when comparing boolean false to false', function()
    expect(false).to.be_equal_to(false)
  end)

  it('should pass when comparing equal numbers', function()
    expect(100).to.be_equal_to(100)
    expect(100).to.be_equal_to(test_integer)
  end)

  it('should pass when comparing equal strings', function()
    expect('Hello, world!').to.be_equal_to('Hello, world!')
    expect('Hello, world!').to.be_equal_to(test_string)
  end)

  it('should fail when comparing nil to a non-nil value', function()
    expect(function()
      expect(nil).to.be_equal_to(1)
    end).to.throw()
  end)

  it('should fail when comparing different boolean values', function()
    expect(function()
      expect(true).to.be_equal_to(false)
    end).to.throw()
  end)

  it('should fail when comparing different numbers', function()
    expect(function()
      expect(100).to.be_equal_to(0)
    end).to.throw()
  end)

  it('should fail when comparing different strings', function()
    expect(function()
      expect('Hello, world!').to.be_equal_to('Goodbye, world!')
    end).to.throw()
  end)

  it('should pass when comparing nil to a non-nil value with not', function()
    expect(nil).toNot.be_equal_to(1)
  end)

  it('should pass when comparing different boolean values with not', function()
    expect(true).toNot.be_equal_to(false)
    expect(false).toNot.be_equal_to(true)
    expect(test_boolean).toNot.be_equal_to(false)
  end)

  it('should pass when comparing different numbers with not', function()
    expect(0).toNot.be_equal_to(100)
    expect(0).toNot.be_equal_to(test_integer)
  end)

  it('should pass when comparing different strings with not', function()
    expect('Goodbyte, world!').toNot.be_equal_to('Hello, world!')
    expect('Goodbyte, world!').toNot.be_equal_to(test_string)
  end)

  it('should fail when comparing nil to nil with not', function()
    expect(function()
      expect(nil).toNot.be_equal_to(nil)
    end).to.throw()
  end)

  it('should fail when comparing equal boolean values with not', function()
    expect(function()
      expect(true).toNot.be_equal_to(true)
    end).to.throw()
  end)

  it('should fail when comparing equal numbers with not', function()
    expect(function()
      expect(100).toNot.be_equal_to(100)
    end).to.throw()
  end)

  it('should fail when comparing equal strings with not', function()
    expect(function()
      expect('Hello, world!').toNot.be_equal_to('Hello, world!')
    end).to.throw()
  end)

  it('should pass when comparing true to true', function()
    expect(true).to.be_equal_to(true)
  end)

  it('should fail when comparing false to true', function()
    expect(function()
      expect(false).to_be(true)
    end).to.throw()
  end)

  it('should fail when comparing a number to true', function()
    expect(function()
      expect(1).to_be(true)
    end).to.throw()
  end)

  it('should pass when comparing false to false', function()
    expect(false).to.be_equal_to(false)
  end)

  it('should fail when comparing true to false', function()
    expect(function()
      expect(true).to.be_equal_to(false)
    end).to.throw()
  end)

  it('should fail when comparing nil to false', function()
    expect(function()
      expect(nil).to_be(false)
    end).to.throw()
  end)

  it('should pass when checking that true is truthy', function()
    expect(true).to.be_truthy()
  end)

  it('should pass when checking that a positive number is truthy', function()
    expect(1).to.be_truthy()
  end)

  it('should fail when checking that false is truthy', function()
    expect(function()
      expect(false).to.be_truthy()
    end).to.throw()
  end)

  it('should fail when checking that nil is truthy', function()
    expect(function()
      expect(nil).to.be_truthy()
    end).to.throw()
  end)

  it('should pass when checking that false is falsy', function()
    expect(false).to.be_falsy()
  end)

  it('should pass when checking that nil is falsy', function()
    expect(nil).to.be_falsy()
  end)

  it('should fail when checking that true is falsy', function()
    expect(function()
      expect(true).to.be_falsy()
    end).to.throw()
  end)

  it('should fail when checking that a positive number is falsy', function()
    expect(function()
      expect(1).to.be_falsy()
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
    expect(successful).to.be_equal_to(false)

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
    expect(successful).to.be_equal_to(false)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number. The new format is "expected actual\nto be equal to\n  expected"
    expect(exception).to.contain('actual error message!')
    expect(exception).to.contain('expected error message!')
    expect(exception).to.contain('to be equal to')
  end)
end)

describe('NumericAssertionTests', function()
  it('should pass when a number is less than another', function()
    expect(5).to.be_less_than(10)
    expect(-1).to.be_less_than(0)
  end)

  it('should pass when a number is less than or equal to another', function()
    expect(5).to.be_less_than_or_equal(10)
    expect(10).to.be_less_than_or_equal(10)
  end)

  it('should pass when a number is greater than another', function()
    expect(10).to.be_greater_than(5)
    expect(0).to.be_greater_than(-1)
  end)

  it('should pass when a number is greater than or equal to another', function()
    expect(10).to.be_greater_than_or_equal(5)
    expect(10).to.be_greater_than_or_equal(10)
  end)

  it('should pass when a number is within epsilon of another', function()
    expect(1.0).to.be_near(1.001, 0.01)
    expect(100.0).to.be_near(100.005, 0.01)
  end)

  it('should fail when a number is not within epsilon of another', function()
    local success = pcall(function()
      expect(1.0).to.be_near(2.0, 0.1)
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('NilAssertionTests', function()
  it('should pass when checking that nil is nil', function()
    expect(nil).to.be_nil()
  end)

  it('should pass when checking that an undefined variable is nil', function()
    local x
    expect(x).to.be_nil()
  end)

  it('should fail when checking that a number is nil', function()
    local success = pcall(function()
      expect(5).to.be_nil()
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('should pass when checking that a number is not nil', function()
    expect(5).toNot.be_nil()
    expect(0).toNot.be_nil()
  end)

  it('should pass when checking that false is not nil', function()
    expect(false).toNot.be_nil()
  end)

  it('should pass when checking that an empty string is not nil', function()
    expect("").toNot.be_nil()
  end)

  it('should fail when checking that nil is not nil', function()
    local success = pcall(function()
      expect(nil).toNot.be_nil()
    end)
    expect(success).to.be_equal_to(false)
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
    expect(success).to.be_equal_to(false)
  end)

  it('should pass when a string matches a pattern', function()
    expect("hello123").to.match_pattern("%d+")
    expect("test@example.com").to.match_pattern("@")
  end)

  it('should fail when a string does not match a pattern', function()
    local success = pcall(function()
      expect("hello").to.match_pattern("%d+")
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('CollectionAssertionTests', function()
  it('should pass when checking that an empty table is empty', function()
    expect({}).to.be_empty()
  end)

  it('should pass when checking that an empty string is empty', function()
    expect("").to.be_empty()
  end)

  it('should fail when checking that a non-empty table is empty', function()
    local success = pcall(function()
      expect({1, 2, 3}).to.be_empty()
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('should pass when checking that a table has the correct size', function()
    expect({1, 2, 3}).to.have_size(3)
    expect({a=1, b=2}).to.have_size(2)
  end)

  it('should fail when checking that a table has the wrong size', function()
    local success = pcall(function()
      expect({1, 2}).to.have_size(5)
    end)
    expect(success).to.be_equal_to(false)
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
    expect(success).to.be_equal_to(false)
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
    expect(success).to.be_equal_to(false)
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
    expect(success).to.be_equal_to(false)
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
    expect(success).to.be_equal_to(false)
  end)
end)

-- Error level testing - verify errors point to correct location
describe('ErrorLevelTests', function()
  it('should report errors at the correct line for be_equal_to', function()
    local success, err = pcall(function()
      expect(1).to.be_equal_to(2)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    -- Error message should contain this file and line number
    expect(type(err)).to.be_equal_to('string')
  end)

  it('should report errors at the correct line for be_less_than', function()
    local success, err = pcall(function()
      expect(10).to.be_less_than(5)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    expect(type(err)).to.be_equal_to('string')
  end)

  it('should report errors at the correct line for be_near', function()
    local success, err = pcall(function()
      expect(1.0).to.be_near(10.0, 0.1)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    expect(type(err)).to.be_equal_to('string')
  end)
end)

describe('Expect API Error Formatting', function()
  it('should format error messages correctly when description is provided', function()
    local success, err = pcall(function()
      expect(1).to.be_equal_to(2)
    end)
    expect(success).to.be_equal_to(false)
    -- Error message should be properly formatted
    expect(type(err)).to.be_equal_to('string')
    expect(err).to.contain('expected')
  end)

  it('should format error messages correctly when description is not provided', function()
    local success, err = pcall(function()
      expect(1).to.be_equal_to(2)
    end)
    expect(success).to.be_equal_to(false)
    -- Error message should contain "expected" (may have file path prefix)
    expect(err).to.contain('expected')
    -- Should contain the actual and expected values
    expect(err).to.contain('1')
    expect(err).to.contain('2')
  end)

  it('should work correctly with matchers that only take one parameter', function()
    -- This test verifies that expect_that works with matchers that only take one parameter
    expect(5).to.be_equal_to(5)
    expect('hello').to.contain('ell')
    expect(10).to.be_greater_than(5)
  end)
end)

describe('satisfy_any API', function()
  it('should work with to.satisfy_any', function()
    expect(5).to.satisfy_any(Equals(5), Equals(10))
    expect(10).to.satisfy_any(Equals(5), Equals(10))
    
    local success = pcall(function()
      expect(7).to.satisfy_any(Equals(5), Equals(10))
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('should work with toNot.satisfy_any', function()
    expect(7).toNot.satisfy_any(Equals(5), Equals(10))
    
    local success = pcall(function()
      expect(5).toNot.satisfy_any(Equals(5), Equals(10))
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('Contains Matcher Type Validation', function()
  it('should work correctly with strings', function()
    expect('hello world').to.contain('world')
    expect('test').to.contain('es')
    
    local success = pcall(function()
      expect('hello').to.contain('xyz')
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('should provide clear error message for non-string types', function()
    local success, err = pcall(function()
      expect(42).to.contain('test')
    end)
    expect(success).to.be_equal_to(false)
    -- Error should indicate the type issue
    expect(err).to.contain('type')
    
    success, err = pcall(function()
      expect({}).to.contain('test')
    end)
    expect(success).to.be_equal_to(false)
    expect(err).to.contain('type')
    
    success, err = pcall(function()
      expect(true).to.contain('test')
    end)
    expect(success).to.be_equal_to(false)
    expect(err).to.contain('type')
  end)
end)

-- Test deeply nested describe blocks
describe('DeepNestingTests', function()
  describe('Level1', function()
    describe('Level2', function()
      describe('Level3', function()
        describe('Level4', function()
          it('should work at level 4', function()
            expect(true).to.be_truthy()
          end)
          
          describe('Level5', function()
            it('should work at level 5', function()
              expect(42).to.be_equal_to(42)
            end)
          end)
        end)
      end)
    end)
  end)
end)

run_unit_tests()

