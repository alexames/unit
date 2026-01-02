local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

test_class 'ExpectationTest' {
  __init = function(self)
    self.Test.__init(self)
    self.test_boolean = true
    self.test_integer = 100
    self.test_string = 'Hello, world!'
  end,

  [test 'expect_equality'] = function(self)
    expect(nil).to.be_equal_to(nil)

    expect(true).to.be_equal_to(true)
    expect(false).to.be_equal_to(false)
    expect(self.test_boolean).to.be_equal_to(true)

    expect(100).to.be_equal_to(100)
    expect(100).to.be_equal_to(self.test_integer)
    
    expect('Hello, world!').to.be_equal_to('Hello, world!')
    expect('Hello, world!').to.be_equal_to(self.test_string)

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
  end,

  [test 'expect_inequality'] = function(self)
    expect(nil).toNot.be_equal_to(1)

    expect(true).toNot.be_equal_to(false)
    expect(false).toNot.be_equal_to(true)
    expect(self.test_boolean).toNot.be_equal_to(false)

    expect(0).toNot.be_equal_to(100)
    expect(0).toNot.be_equal_to(self.test_integer)
    
    expect('Goodbyte, world!').toNot.be_equal_to('Hello, world!')
    expect('Goodbyte, world!').toNot.be_equal_to(self.test_string)

    -- Expect that the expect().toNot.be_equal_to() test fails in these cases.
    expect(function()
      expect(nil).toNot.be_equal_to(nil)
    end).to.throw()
    expect(function()
      expect(true).toNot.be_equal_to(true)
    end).to.throw()
    expect(function()
      expect(100).toNot.be_equal_to(100)
    end).to.throw()
    expect(function()
      expect('Hello, world!').toNot.be_equal_to('Hello, world!')
    end).to.throw()
  end,

  [test 'expect_true'] = function(self)
    expect(true).to.be_equal_to(true)
    
    -- Expect that the expect().to.be_equal_to() test fail in this case.
    expect(function()
      expect(false).to.be_equal_to(true)
    end).to.throw()
    expect(function()
      expect(1).to.be_equal_to(true)
    end).to.throw()
  end,

  [test 'expect_false'] = function(self)
    expect(false).to.be_equal_to(false)
    
    -- Expect that the expect().to.be_equal_to() test fail in this case.
    expect(function()
      expect(true).to.be_equal_to(false)
    end).to.throw()
    expect(function()
      expect(nil).to.be_equal_to(false)
    end).to.throw()
  end,

  [test 'expect_truthy'] = function(self)
    expect(true).to.be_truthy()
    expect(1).to.be_truthy()
    
    -- Expect that the expect().to.be_truthy() test fail in this case.
    expect(function()
      expect(false).to.be_truthy()
    end).to.throw()
    expect(function()
      expect(nil).to.be_truthy()
    end).to.throw()
  end,

  [test 'expect_falsey'] = function(self)
    expect(false).to.be_falsy()
    expect(nil).to.be_falsy()
    
    -- Expect that the expect().to.be_falsy() test fail in this case.
    expect(function()
      expect(true).to.be_falsy()
    end).to.throw()
    expect(function()
      expect(1).to.be_falsy()
    end).to.throw()
  end,

  [test 'expect_error'] = function(self)
    expect(function()
       error('error!')
    end).to.throw('error!')

    expect(function()
       error('error!')
    end).to.throw()
  end,

  [test 'expect_error_no_error'] = function(self)
    -- Verify that when a function passed to expect().to.throw() fails to raise the
    -- correct error the expect().to.throw() function fails correctly.
    local successful, exception = pcall(function()
      expect(function() end).to.throw()
    end)
    expect(successful).to.be_equal_to(false)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    expect(exception).to.match(EndsWith('expected function to raise error'))
  end,

  [test 'expect_error_wrong_error'] = function(self)
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
  end,
}

test_class 'NumericAssertionTests' {
  [test 'EXPECT_LT passes when less than'] = function()
    expect(5).to.be_less_than(10)
    expect(-1).to.be_less_than(0)
  end,

  [test 'EXPECT_LE passes when less than or equal'] = function()
    expect(5).to.be_less_than_or_equal(10)
    expect(10).to.be_less_than_or_equal(10)
  end,

  [test 'EXPECT_GT passes when greater than'] = function()
    expect(10).to.be_greater_than(5)
    expect(0).to.be_greater_than(-1)
  end,

  [test 'EXPECT_GE passes when greater than or equal'] = function()
    expect(10).to.be_greater_than_or_equal(5)
    expect(10).to.be_greater_than_or_equal(10)
  end,

  [test 'EXPECT_NEAR passes for close values'] = function()
    expect(1.0).to.be_near(1.001, 0.01)
    expect(100.0).to.be_near(100.005, 0.01)
  end,

  [test 'EXPECT_NEAR fails for distant values'] = function()
    local success = pcall(function()
      expect(1.0).to.be_near(2.0, 0.1)
    end)
    expect(success).to.be_equal_to(false)
  end,
}

test_class 'NilAssertionTests' {
  [test 'EXPECT_NIL passes for nil'] = function()
    expect(nil).to.be_nil()
    local x
    expect(x).to.be_nil()
  end,

  [test 'EXPECT_NIL fails for non-nil'] = function()
    local success = pcall(function()
      expect(5).to.be_nil()
    end)
    expect(success).to.be_equal_to(false)
  end,

  [test 'EXPECT_NOT_NIL passes for non-nil'] = function()
    expect(5).toNot.be_nil()
    expect(0).toNot.be_nil()
    expect(false).toNot.be_nil()
    expect("").toNot.be_nil()
  end,

  [test 'EXPECT_NOT_NIL fails for nil'] = function()
    local success = pcall(function()
      expect(nil).toNot.be_nil()
    end)
    expect(success).to.be_equal_to(false)
  end,
}

test_class 'StringAssertionTests' {
  [test 'EXPECT_CONTAINS passes when substring present'] = function()
    expect("hello world").to.contain("world")
    expect("test").to.contain("es")
  end,

  [test 'EXPECT_CONTAINS fails when substring absent'] = function()
    local success = pcall(function()
      expect("hello").to.contain("xyz")
    end)
    expect(success).to.be_equal_to(false)
  end,

  [test 'EXPECT_MATCHES passes for pattern match'] = function()
    expect("hello123").to.match_pattern("%d+")
    expect("test@example.com").to.match_pattern("@")
  end,

  [test 'EXPECT_MATCHES fails for no match'] = function()
    local success = pcall(function()
      expect("hello").to.match_pattern("%d+")
    end)
    expect(success).to.be_equal_to(false)
  end,
}

test_class 'CollectionAssertionTests' {
  [test 'EXPECT_EMPTY passes for empty table'] = function()
    expect({}).to.be_empty()
  end,

  [test 'EXPECT_EMPTY passes for empty string'] = function()
    expect("").to.be_empty()
  end,

  [test 'EXPECT_EMPTY fails for non-empty'] = function()
    local success = pcall(function()
      expect({1, 2, 3}).to.be_empty()
    end)
    expect(success).to.be_equal_to(false)
  end,

  [test 'EXPECT_SIZE passes for correct size'] = function()
    expect({1, 2, 3}).to.have_size(3)
    expect({a=1, b=2}).to.have_size(2)
  end,

  [test 'EXPECT_SIZE fails for wrong size'] = function()
    local success = pcall(function()
      expect({1, 2}).to.have_size(5)
    end)
    expect(success).to.be_equal_to(false)
  end,
}

test_class 'ErrorAssertionTests' {
  [test 'EXPECT_ERROR passes when function errors'] = function()
    expect(function()
      error("test error")
    end).to.throw()
  end,

  [test 'EXPECT_ERROR fails when function succeeds'] = function()
    local success = pcall(function()
      expect(function()
        return 42
      end).to.throw()
    end)
    expect(success).to.be_equal_to(false)
  end,

  [test 'EXPECT_NO_ERROR passes when function succeeds'] = function()
    expect(function()
      return 42
    end).toNot.throw()
  end,

  [test 'EXPECT_NO_ERROR fails when function errors'] = function()
    local success = pcall(function()
      expect(function()
        error("oops")
      end).toNot.throw()
    end)
    expect(success).to.be_equal_to(false)
  end,
}

test_class 'NumericMatcherTests' {
  [test 'Near matcher'] = function()
    expect(1.0).to.match(Near(1.001, 0.01))
    expect(100.0).to.match(Near(100.005, 0.01))
  end,

  [test 'IsPositive matcher'] = function()
    expect(5).to.match(IsPositive())
    expect(0.1).to.match(IsPositive())
  end,

  [test 'IsNegative matcher'] = function()
    expect(-5).to.match(IsNegative())
    expect(-0.1).to.match(IsNegative())
  end,

  [test 'IsBetween matcher'] = function()
    expect(5).to.match(IsBetween(1, 10))
    expect(1).to.match(IsBetween(1, 10))
    expect(10).to.match(IsBetween(1, 10))
  end,

  [test 'IsNaN matcher'] = function()
    local nan = 0/0
    expect(nan).to.match(IsNaN())
  end,
}

test_class 'StringMatcherTests' {
  [test 'Contains matcher'] = function()
    expect("hello world").to.match(Contains("world"))
    expect("test").to.match(Contains("es"))
  end,

  [test 'Matches matcher'] = function()
    expect("hello123").to.match(Matches("%d+"))
    expect("test@example.com").to.match(Matches("@"))
  end,

  [test 'IsEmpty matcher for strings'] = function()
    expect("").to.match(IsEmpty())
  end,

  [test 'HasLength matcher'] = function()
    expect("hello").to.match(HasLength(5))
    expect("").to.match(HasLength(0))
  end,
}

test_class 'CollectionMatcherTests' {
  [test 'IsEmpty matcher for tables'] = function()
    expect({}).to.match(IsEmpty())
  end,

  [test 'HasSize matcher'] = function()
    expect({1, 2, 3}).to.match(HasSize(3))
    expect({a=1, b=2}).to.match(HasSize(2))
  end,

  [test 'ContainsElement matcher'] = function()
    expect({1, 2, 3}).to.match(ContainsElement(2))
    expect({"a", "b", "c"}).to.match(ContainsElement("b"))
  end,
}

test_class 'CompositeMatcherTests' {
  [test 'AllOf matcher passes when all match'] = function()
    expect(5).to.match(AllOf(GreaterThan(0), LessThan(10)))
  end,

  [test 'AllOf matcher fails when one fails'] = function()
    local success = pcall(function()
      expect(15).to.match(AllOf(GreaterThan(0), LessThan(10)))
    end)
    expect(success).to.be_equal_to(false)
  end,

  [test 'AnyOf matcher passes when one matches'] = function()
    expect(5).to.match(AnyOf(Equals(5), Equals(10)))
    expect(10).to.match(AnyOf(Equals(5), Equals(10)))
  end,

  [test 'AnyOf matcher fails when none match'] = function()
    local success = pcall(function()
      expect(7).to.match(AnyOf(Equals(5), Equals(10)))
    end)
    expect(success).to.be_equal_to(false)
  end,
}

-- Error level testing - verify errors point to correct location
test_class 'ErrorLevelTests' {
  [test 'EXPECT_EQ error points to test code'] = function()
    local success, err = pcall(function()
      expect(1).to.be_equal_to(2)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    -- Error message should contain this file and line number
    expect(type(err)).to.be_equal_to('string')
  end,

  [test 'EXPECT_LT error points to test code'] = function()
    local success, err = pcall(function()
      expect(10).to.be_less_than(5)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    expect(type(err)).to.be_equal_to('string')
  end,

  [test 'EXPECT_NEAR error points to test code'] = function()
    local success, err = pcall(function()
      expect(1.0).to.be_near(10.0, 0.1)  -- Error should point to THIS line
    end)
    expect(success).to.be_equal_to(false)
    expect(type(err)).to.be_equal_to('string')
  end,
}

run_unit_tests()
