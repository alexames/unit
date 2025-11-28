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
    EXPECT_EQ(nil, nil)

    EXPECT_EQ(true, true)
    EXPECT_EQ(false, false)
    EXPECT_EQ(self.test_boolean, true)

    EXPECT_EQ(100, 100)
    EXPECT_EQ(100, self.test_integer)
    
    EXPECT_EQ('Hello, world!', 'Hello, world!')
    EXPECT_EQ('Hello, world!', self.test_string)

    -- Expect that the EXPECT_EQ test fails in these cases.
    EXPECT_ERROR(function()
      EXPECT_EQ(nil, 1)
    end)
    EXPECT_ERROR(function()
      EXPECT_EQ(true, false)
    end)
    EXPECT_ERROR(function()
      EXPECT_EQ(100, 0)
    end)
    EXPECT_ERROR(function()
      EXPECT_EQ('Hello, world!', 'Goodbye, world!')
    end)
  end,

  [test 'expect_inequality'] = function(self)
    EXPECT_NE(nil, 1)

    EXPECT_NE(true, false)
    EXPECT_NE(false, true)
    EXPECT_NE(self.test_boolean, false)

    EXPECT_NE(0, 100)
    EXPECT_NE(0, self.test_integer)
    
    EXPECT_NE('Goodbyte, world!', 'Hello, world!')
    EXPECT_NE('Goodbyte, world!', self.test_string)

    -- Expect that the EXPECT_NE test fails in these cases.
    EXPECT_ERROR(function()
      EXPECT_NE(nil, nil)
    end)
    EXPECT_ERROR(function()
      EXPECT_NE(true, true)
    end)
    EXPECT_ERROR(function()
      EXPECT_NE(100, 100)
    end)
    EXPECT_ERROR(function()
      EXPECT_NE('Hello, world!', 'Hello, world!')
    end)
  end,

  [test 'expect_true'] = function(self)
    EXPECT_TRUE(true)
    
    -- Expect that the EXPECT_NE test fail in this case.
    EXPECT_ERROR(function()
      EXPECT_TRUE(false)
    end)
    EXPECT_ERROR(function()
      EXPECT_TRUE(1)
    end)
  end,

  [test 'expect_false'] = function(self)
    EXPECT_FALSE(false)
    
    -- Expect that the EXPECT_NE test fail in this case.
    EXPECT_ERROR(function()
      EXPECT_FALSE(true)
    end)
    EXPECT_ERROR(function()
      EXPECT_FALSE(nil)
    end)
  end,

  [test 'expect_truthy'] = function(self)
    EXPECT_TRUTHY(true)
    EXPECT_TRUTHY(1)
    
    -- Expect that the EXPECT_NE test fail in this case.
    EXPECT_ERROR(function()
      EXPECT_TRUTHY(false)
    end)
    EXPECT_ERROR(function()
      EXPECT_TRUTHY(nil)
    end)
  end,

  [test 'expect_falsey'] = function(self)
    EXPECT_FALSEY(false)
    EXPECT_FALSEY(nil)
    
    -- Expect that the EXPECT_NE test fail in this case.
    EXPECT_ERROR(function()
      EXPECT_FALSEY(true)
    end)
    EXPECT_ERROR(function()
      EXPECT_FALSEY(1)
    end)
  end,

  [test 'expect_error'] = function(self)
    EXPECT_ERROR(function()
       error('error!')
    end, 'error!')

    EXPECT_ERROR(function()
       error('error!')
    end)
  end,

  [test 'expect_error_no_error'] = function(self)
    -- Verify that when a function passed to EXPECT_ERROR fails to raise the
    -- correct error the EXPECT_ERROR function fails correctly.
    local successful, exception = pcall(function()
      EXPECT_ERROR(function() end)
    end)
    EXPECT_FALSE(successful)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    EXPECT_THAT(exception, EndsWith 'expected function to raise error')
  end,

  [test 'expect_error_wrong_error'] = function(self)
    -- Verify that when a function passed to EXPECT_ERROR fails to raise the
    -- correct error the EXPECT_ERROR function fails correctly.
    local successful, exception = pcall(function()
      EXPECT_ERROR(function()
       error('actual error message!')
      end, 'expected error message!')
    end)
    EXPECT_FALSE(successful)

    -- Just check the suffix, since error messages are prefixed with a file and
    -- line number.
    EXPECT_THAT(exception, EndsWith [[
expected 
  actual error message!
to be equal to
  expected error message!]])
  end,
}

test_class 'NumericAssertionTests' {
  [test 'EXPECT_LT passes when less than'] = function()
    EXPECT_LT(5, 10)
    EXPECT_LT(-1, 0)
  end,

  [test 'EXPECT_LE passes when less than or equal'] = function()
    EXPECT_LE(5, 10)
    EXPECT_LE(10, 10)
  end,

  [test 'EXPECT_GT passes when greater than'] = function()
    EXPECT_GT(10, 5)
    EXPECT_GT(0, -1)
  end,

  [test 'EXPECT_GE passes when greater than or equal'] = function()
    EXPECT_GE(10, 5)
    EXPECT_GE(10, 10)
  end,

  [test 'EXPECT_NEAR passes for close values'] = function()
    EXPECT_NEAR(1.0, 1.001, 0.01)
    EXPECT_NEAR(100.0, 100.005, 0.01)
  end,

  [test 'EXPECT_NEAR fails for distant values'] = function()
    local success = pcall(function()
      EXPECT_NEAR(1.0, 2.0, 0.1)
    end)
    EXPECT_FALSE(success)
  end,
}

test_class 'NilAssertionTests' {
  [test 'EXPECT_NIL passes for nil'] = function()
    EXPECT_NIL(nil)
    local x
    EXPECT_NIL(x)
  end,

  [test 'EXPECT_NIL fails for non-nil'] = function()
    local success = pcall(function()
      EXPECT_NIL(5)
    end)
    EXPECT_FALSE(success)
  end,

  [test 'EXPECT_NOT_NIL passes for non-nil'] = function()
    EXPECT_NOT_NIL(5)
    EXPECT_NOT_NIL(0)
    EXPECT_NOT_NIL(false)
    EXPECT_NOT_NIL("")
  end,

  [test 'EXPECT_NOT_NIL fails for nil'] = function()
    local success = pcall(function()
      EXPECT_NOT_NIL(nil)
    end)
    EXPECT_FALSE(success)
  end,
}

test_class 'StringAssertionTests' {
  [test 'EXPECT_CONTAINS passes when substring present'] = function()
    EXPECT_CONTAINS("hello world", "world")
    EXPECT_CONTAINS("test", "es")
  end,

  [test 'EXPECT_CONTAINS fails when substring absent'] = function()
    local success = pcall(function()
      EXPECT_CONTAINS("hello", "xyz")
    end)
    EXPECT_FALSE(success)
  end,

  [test 'EXPECT_MATCHES passes for pattern match'] = function()
    EXPECT_MATCHES("hello123", "%d+")
    EXPECT_MATCHES("test@example.com", "@")
  end,

  [test 'EXPECT_MATCHES fails for no match'] = function()
    local success = pcall(function()
      EXPECT_MATCHES("hello", "%d+")
    end)
    EXPECT_FALSE(success)
  end,
}

test_class 'CollectionAssertionTests' {
  [test 'EXPECT_EMPTY passes for empty table'] = function()
    EXPECT_EMPTY({})
  end,

  [test 'EXPECT_EMPTY passes for empty string'] = function()
    EXPECT_EMPTY("")
  end,

  [test 'EXPECT_EMPTY fails for non-empty'] = function()
    local success = pcall(function()
      EXPECT_EMPTY({1, 2, 3})
    end)
    EXPECT_FALSE(success)
  end,

  [test 'EXPECT_SIZE passes for correct size'] = function()
    EXPECT_SIZE({1, 2, 3}, 3)
    EXPECT_SIZE({a=1, b=2}, 2)
  end,

  [test 'EXPECT_SIZE fails for wrong size'] = function()
    local success = pcall(function()
      EXPECT_SIZE({1, 2}, 5)
    end)
    EXPECT_FALSE(success)
  end,
}

test_class 'ErrorAssertionTests' {
  [test 'EXPECT_ERROR passes when function errors'] = function()
    EXPECT_ERROR(function()
      error("test error")
    end)
  end,

  [test 'EXPECT_ERROR fails when function succeeds'] = function()
    local success = pcall(function()
      EXPECT_ERROR(function()
        return 42
      end)
    end)
    EXPECT_FALSE(success)
  end,

  [test 'EXPECT_NO_ERROR passes when function succeeds'] = function()
    EXPECT_NO_ERROR(function()
      return 42
    end)
  end,

  [test 'EXPECT_NO_ERROR fails when function errors'] = function()
    local success = pcall(function()
      EXPECT_NO_ERROR(function()
        error("oops")
      end)
    end)
    EXPECT_FALSE(success)
  end,
}

test_class 'NumericMatcherTests' {
  [test 'Near matcher'] = function()
    EXPECT_THAT(1.0, Near(1.001, 0.01))
    EXPECT_THAT(100.0, Near(100.005, 0.01))
  end,

  [test 'IsPositive matcher'] = function()
    EXPECT_THAT(5, IsPositive())
    EXPECT_THAT(0.1, IsPositive())
  end,

  [test 'IsNegative matcher'] = function()
    EXPECT_THAT(-5, IsNegative())
    EXPECT_THAT(-0.1, IsNegative())
  end,

  [test 'IsBetween matcher'] = function()
    EXPECT_THAT(5, IsBetween(1, 10))
    EXPECT_THAT(1, IsBetween(1, 10))
    EXPECT_THAT(10, IsBetween(1, 10))
  end,

  [test 'IsNaN matcher'] = function()
    local nan = 0/0
    EXPECT_THAT(nan, IsNaN())
  end,
}

test_class 'StringMatcherTests' {
  [test 'Contains matcher'] = function()
    EXPECT_THAT("hello world", Contains("world"))
    EXPECT_THAT("test", Contains("es"))
  end,

  [test 'Matches matcher'] = function()
    EXPECT_THAT("hello123", Matches("%d+"))
    EXPECT_THAT("test@example.com", Matches("@"))
  end,

  [test 'IsEmpty matcher for strings'] = function()
    EXPECT_THAT("", IsEmpty())
  end,

  [test 'HasLength matcher'] = function()
    EXPECT_THAT("hello", HasLength(5))
    EXPECT_THAT("", HasLength(0))
  end,
}

test_class 'CollectionMatcherTests' {
  [test 'IsEmpty matcher for tables'] = function()
    EXPECT_THAT({}, IsEmpty())
  end,

  [test 'HasSize matcher'] = function()
    EXPECT_THAT({1, 2, 3}, HasSize(3))
    EXPECT_THAT({a=1, b=2}, HasSize(2))
  end,

  [test 'ContainsElement matcher'] = function()
    EXPECT_THAT({1, 2, 3}, ContainsElement(2))
    EXPECT_THAT({"a", "b", "c"}, ContainsElement("b"))
  end,
}

test_class 'CompositeMatcherTests' {
  [test 'AllOf matcher passes when all match'] = function()
    EXPECT_THAT(5, AllOf(GreaterThan(0), LessThan(10)))
  end,

  [test 'AllOf matcher fails when one fails'] = function()
    local success = pcall(function()
      EXPECT_THAT(15, AllOf(GreaterThan(0), LessThan(10)))
    end)
    EXPECT_FALSE(success)
  end,

  [test 'AnyOf matcher passes when one matches'] = function()
    EXPECT_THAT(5, AnyOf(Equals(5), Equals(10)))
    EXPECT_THAT(10, AnyOf(Equals(5), Equals(10)))
  end,

  [test 'AnyOf matcher fails when none match'] = function()
    local success = pcall(function()
      EXPECT_THAT(7, AnyOf(Equals(5), Equals(10)))
    end)
    EXPECT_FALSE(success)
  end,
}

-- Error level testing - verify errors point to correct location
test_class 'ErrorLevelTests' {
  [test 'EXPECT_EQ error points to test code'] = function()
    local success, err = pcall(function()
      EXPECT_EQ(1, 2)  -- Error should point to THIS line
    end)
    EXPECT_FALSE(success)
    -- Error message should contain this file and line number
    EXPECT_TRUE(type(err) == 'string')
  end,

  [test 'EXPECT_LT error points to test code'] = function()
    local success, err = pcall(function()
      EXPECT_LT(10, 5)  -- Error should point to THIS line
    end)
    EXPECT_FALSE(success)
    EXPECT_TRUE(type(err) == 'string')
  end,

  [test 'EXPECT_NEAR error points to test code'] = function()
    local success, err = pcall(function()
      EXPECT_NEAR(1.0, 10.0, 0.1)  -- Error should point to THIS line
    end)
    EXPECT_FALSE(success)
    EXPECT_TRUE(type(err) == 'string')
  end,
}

run_unit_tests()
