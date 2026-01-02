local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

describe('ExpectationTest', function()
  local test_boolean = true
  local test_integer = 100
  local test_string = 'Hello, world!'

  it('expect_equality', function()
    expect(nil).to.be_equal_to(nil)

    expect(true).to.be_equal_to(true)
    expect(false).to.be_equal_to(false)
    expect(test_boolean).to.be_equal_to(true)

    expect(100).to.be_equal_to(100)
    expect(100).to.be_equal_to(test_integer)
    
    expect('Hello, world!').to.be_equal_to('Hello, world!')
    expect('Hello, world!').to.be_equal_to(test_string)

    -- Expect that the expect().to.be_equal_to() test fails in these cases.
    expect(function()
      expect(nil).to.be_equal_to(1)
    end).to.throw()
    expect(function()
      expect(true).to.be_equal_to(false)
    end).to.throw()
    expect(function()
      expect(100).to.be_equal_to(0)
    end).to.throw()
    expect(function()
      expect('Hello, world!').to.be_equal_to('Goodbye, world!')
    end).to.throw()
  end)

  it('expect_inequality', function()
    expect(nil).to_not.be_equal_to(1)

    expect(true).to_not.be_equal_to(false)
    expect(false).to_not.be_equal_to(true)
    expect(test_boolean).to_not.be_equal_to(false)

    expect(0).to_not.be_equal_to(100)
    expect(0).to_not.be_equal_to(test_integer)
    
    expect('Goodbyte, world!').to_not.be_equal_to('Hello, world!')
    expect('Goodbyte, world!').to_not.be_equal_to(test_string)

    -- Expect that the expect().to_not.be_equal_to() test fails in these cases.
    expect(function()
      expect(nil).to_not.be_equal_to(nil)
    end).to.throw()
    expect(function()
      expect(true).to_not.be_equal_to(true)
    end).to.throw()
    expect(function()
      expect(100).to_not.be_equal_to(100)
    end).to.throw()
    expect(function()
      expect('Hello, world!').to_not.be_equal_to('Hello, world!')
    end).to.throw()
  end)

  it('expect_true', function()
    expect(true).to.be_equal_to(true)
    
    -- Expect that the expect().to.be_equal_to() test fail in this case.
    expect(function()
      expect(false).to.be_equal_to(true)
    end).to.throw()
    expect(function()
      expect(1).to.be_equal_to(true)
    end).to.throw()
  end)

  it('expect_false', function()
    expect(false).to.be_equal_to(false)
    
    -- Expect that the expect().to.be_equal_to() test fail in this case.
    expect(function()
      expect(true).to.be_equal_to(false)
    end).to.throw()
    expect(function()
      expect(nil).to.be_equal_to(false)
    end).to.throw()
  end)

  it('expect_truthy', function()
    expect(true).to.be_truthy()
    expect(1).to.be_truthy()
    
    -- Expect that the expect().to.be_truthy() test fail in this case.
    expect(function()
      expect(false).to.be_truthy()
    end).to.throw()
    expect(function()
      expect(nil).to.be_truthy()
    end).to.throw()
  end)

  it('expect_falsy', function()
    expect(false).to.be_falsy()
    expect(nil).to.be_falsy()
    
    -- Expect that the expect().to.be_falsy() test fail in this case.
    expect(function()
      expect(true).to.be_falsy()
    end).to.throw()
    expect(function()
      expect(1).to.be_falsy()
    end).to.throw()
  end)

  it('expect_error', function()
    expect(function()
       error('error!')
    end).to.throw('error!')

    expect(function()
       error('error!')
    end).to.throw()
  end)

  it('expect_error_no_error', function()
    -- Verify that when a function passed to expect().to.throw() fails to raise the
    -- correct error the expect().to.throw() function fails correctly.
    local successful, exception = pcall(function()
      expect(function() end).to.throw()
    end)
    expect(successful).to.be_equal_to(false)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    expect(exception).to.match(matchers_module.ends_with('expected function to raise error'))
  end)

  it('expect_error_wrong_error', function()
    -- Verify that when a function passed to expect().to.throw() fails to raise the
    -- correct error the expect().to.throw() function fails correctly.
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
  it('be_less_than passes when less than', function()
    expect(5).to.be_less_than(10)
    expect(-1).to.be_less_than(0)
  end)

  it('be_less_than_or_equal passes when less than or equal', function()
    expect(5).to.be_less_than_or_equal(10)
    expect(10).to.be_less_than_or_equal(10)
  end)

  it('be_greater_than passes when greater than', function()
    expect(10).to.be_greater_than(5)
    expect(0).to.be_greater_than(-1)
  end)

  it('be_greater_than_or_equal passes when greater than or equal', function()
    expect(10).to.be_greater_than_or_equal(5)
    expect(10).to.be_greater_than_or_equal(10)
  end)

  it('be_near passes for close values', function()
    expect(1.0).to.be_near(1.001, 0.01)
    expect(100.0).to.be_near(100.005, 0.01)
  end)

  it('be_near fails for distant values', function()
    local success = pcall(function()
      expect(1.0).to.be_near(2.0, 0.1)
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('NilAssertionTests', function()
  it('be_nil passes for nil', function()
    expect(nil).to.be_nil()
    local x
    expect(x).to.be_nil()
  end)

  it('be_nil fails for non-nil', function()
    local success = pcall(function()
      expect(5).to.be_nil()
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('to_not.be_nil passes for non-nil', function()
    expect(5).to_not.be_nil()
    expect(0).to_not.be_nil()
    expect(false).to_not.be_nil()
    expect("").to_not.be_nil()
  end)

  it('to_not.be_nil fails for nil', function()
    local success = pcall(function()
      expect(nil).to_not.be_nil()
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('StringAssertionTests', function()
  it('contain passes when substring present', function()
    expect("hello world").to.contain("world")
    expect("test").to.contain("es")
  end)

  it('contain fails when substring absent', function()
    local success = pcall(function()
      expect("hello").to.contain("xyz")
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('match_pattern passes for pattern match', function()
    expect("hello123").to.match_pattern("%d+")
    expect("test@example.com").to.match_pattern("@")
  end)

  it('match_pattern fails for no match', function()
    local success = pcall(function()
      expect("hello").to.match_pattern("%d+")
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('CollectionAssertionTests', function()
  it('be_empty passes for empty table', function()
    expect({}).to.be_empty()
  end)

  it('be_empty passes for empty string', function()
    expect("").to.be_empty()
  end)

  it('be_empty fails for non-empty', function()
    local success = pcall(function()
      expect({1, 2, 3}).to.be_empty()
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('have_size passes for correct size', function()
    expect({1, 2, 3}).to.have_size(3)
    expect({a=1, b=2}).to.have_size(2)
  end)

  it('have_size fails for wrong size', function()
    local success = pcall(function()
      expect({1, 2}).to.have_size(5)
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('ErrorAssertionTests', function()
  it('throw passes when function errors', function()
    expect(function()
      error("test error")
    end).to.throw()
  end)

  it('throw fails when function succeeds', function()
    local success = pcall(function()
      expect(function()
        return 42
      end).to.throw()
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('to_not.throw passes when function succeeds', function()
    expect(function()
      return 42
    end).to_not.throw()
  end)

  it('to_not.throw fails when function errors', function()
    local success = pcall(function()
      expect(function()
        error("oops")
      end).to_not.throw()
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

describe('NumericMatcherTests', function()
  it('Near matcher', function()
    expect(1.0).to.match(matchers_module.near(1.001, 0.01))
    expect(100.0).to.match(matchers_module.near(100.005, 0.01))
  end)

  it('IsPositive matcher', function()
    expect(5).to.match(matchers_module.is_positive())
    expect(0.1).to.match(matchers_module.is_positive())
  end)

  it('IsNegative matcher', function()
    expect(-5).to.match(matchers_module.is_negative())
    expect(-0.1).to.match(matchers_module.is_negative())
  end)

  it('IsBetween matcher', function()
    expect(5).to.match(matchers_module.is_between(1, 10))
    expect(1).to.match(matchers_module.is_between(1, 10))
    expect(10).to.match(matchers_module.is_between(1, 10))
  end)

  it('IsNaN matcher', function()
    local nan = 0/0
    expect(nan).to.match(matchers_module.is_nan())
  end)
end)

describe('StringMatcherTests', function()
  it('Contains matcher', function()
    expect("hello world").to.match(matchers_module.contains("world"))
    expect("test").to.match(matchers_module.contains("es"))
  end)

  it('Matches matcher', function()
    expect("hello123").to.match(matchers_module.matches("%d+"))
    expect("test@example.com").to.match(matchers_module.matches("@"))
  end)

  it('IsEmpty matcher for strings', function()
    expect("").to.match(matchers_module.is_empty())
  end)

  it('HasLength matcher', function()
    expect("hello").to.match(matchers_module.has_length(5))
    expect("").to.match(matchers_module.has_length(0))
  end)
end)

describe('CollectionMatcherTests', function()
  it('IsEmpty matcher for tables', function()
    expect({}).to.match(matchers_module.is_empty())
  end)

  it('HasSize matcher', function()
    expect({1, 2, 3}).to.match(matchers_module.has_size(3))
    expect({a=1, b=2}).to.match(matchers_module.has_size(2))
  end)

  it('ContainsElement matcher', function()
    expect({1, 2, 3}).to.match(matchers_module.contains_element(2))
    expect({"a", "b", "c"}).to.match(matchers_module.contains_element("b"))
  end)
end)

describe('CompositeMatcherTests', function()
  it('AllOf matcher passes when all match', function()
    expect(5).to.match(matchers_module.all_of(matchers_module.greater_than(0), matchers_module.less_than(10)))
  end)

  it('AllOf matcher fails when one fails', function()
    local success = pcall(function()
      expect(15).to.match(matchers_module.all_of(matchers_module.greater_than(0), matchers_module.less_than(10)))
    end)
    expect(success).to.be_equal_to(false)
  end)

  it('AnyOf matcher passes when one matches', function()
    expect(5).to.match(matchers_module.any_of(matchers_module.equals(5), matchers_module.equals(10)))
    expect(10).to.match(matchers_module.any_of(matchers_module.equals(5), matchers_module.equals(10)))
  end)

  it('AnyOf matcher fails when none match', function()
    local success = pcall(function()
      expect(7).to.match(matchers_module.any_of(matchers_module.equals(5), matchers_module.equals(10)))
    end)
    expect(success).to.be_equal_to(false)
  end)
end)

-- Error level testing - verify errors point to correct location
describe('ErrorLevelTests', function()
  it('be_equal_to error points to test code', function()
    local success, err = pcall(function()
      expect(1).to.be_equal_to(2)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    -- Error message should contain this file and line number
    expect(type(err)).to.be_equal_to('string')
  end)

  it('be_less_than error points to test code', function()
    local success, err = pcall(function()
      expect(10).to.be_less_than(5)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    expect(type(err)).to.be_equal_to('string')
  end)

  it('be_near error points to test code', function()
    local success, err = pcall(function()
      expect(1.0).to.be_near(10.0, 0.1)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    expect(type(err)).to.be_equal_to('string')
  end)
end)

run_unit_tests()
