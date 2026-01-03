-- Tests for all matchers

local unit = require 'unit.test_api'
local llx = require 'llx'
local matchers = require 'unit.matchers'

local describe = unit.describe
local it = unit.it
local expect = unit.expect

describe('Matchers', function()

  describe('equals', function()
    it('should match equal values', function()
      expect(5).to.be_equal_to(5)
      expect('hello').to.be_equal_to('hello')
      expect(true).to.be_equal_to(true)
      expect(nil).to.be_equal_to(nil)
    end)

    it('should fail for different values', function()
      expect(function()
        expect(5).to.be_equal_to(10)
      end).to.throw()
    end)

    it('should work with to_not', function()
      expect(5).to_not.be_equal_to(10)
      expect('hello').to_not.be_equal_to('world')
    end)
  end)

  describe('greater_than', function()
    it('should match when value is greater', function()
      expect(10).to.be_greater_than(5)
      expect(5).to.be_greater_than(0)
    end)

    it('should fail when value is not greater', function()
      expect(function()
        expect(5).to.be_greater_than(10)
      end).to.throw()
    end)
  end)

  describe('greater_than_or_equal', function()
    it('should match when value is greater or equal', function()
      expect(10).to.be_greater_than_or_equal(5)
      expect(5).to.be_greater_than_or_equal(5)
    end)

    it('should fail when value is less', function()
      expect(function()
        expect(5).to.be_greater_than_or_equal(10)
      end).to.throw()
    end)
  end)

  describe('less_than', function()
    it('should match when value is less', function()
      expect(5).to.be_less_than(10)
      expect(0).to.be_less_than(5)
    end)

    it('should fail when value is not less', function()
      expect(function()
        expect(10).to.be_less_than(5)
      end).to.throw()
    end)
  end)

  describe('less_than_or_equal', function()
    it('should match when value is less or equal', function()
      expect(5).to.be_less_than_or_equal(10)
      expect(5).to.be_less_than_or_equal(5)
    end)

    it('should fail when value is greater', function()
      expect(function()
        expect(10).to.be_less_than_or_equal(5)
      end).to.throw()
    end)
  end)

  describe('be_nil', function()
    it('should match nil values', function()
      expect(nil).to.be_nil()
    end)

    it('should fail for non-nil values', function()
      expect(function()
        expect(5).to.be_nil()
      end).to.throw()
    end)
  end)

  describe('be_true', function()
    it('should match true', function()
      expect(true).to.be_true()
    end)

    it('should fail for false', function()
      expect(function()
        expect(false).to.be_true()
      end).to.throw()
    end)

    it('should fail for truthy values', function()
      expect(function()
        expect(1).to.be_true()
      end).to.throw()
    end)
  end)

  describe('be_false', function()
    it('should match false', function()
      expect(false).to.be_false()
    end)

    it('should fail for true', function()
      expect(function()
        expect(true).to.be_false()
      end).to.throw()
    end)

    it('should fail for falsy values', function()
      expect(function()
        expect(nil).to.be_false()
      end).to.throw()
    end)
  end)

  describe('be_truthy', function()
    it('should match truthy values', function()
      expect(true).to.be_truthy()
      expect(1).to.be_truthy()
      expect('hello').to.be_truthy()
      expect({}).to.be_truthy()
    end)

    it('should fail for false', function()
      expect(function()
        expect(false).to.be_truthy()
      end).to.throw()
    end)

    it('should fail for nil', function()
      expect(function()
        expect(nil).to.be_truthy()
      end).to.throw()
    end)
  end)

  describe('be_falsy', function()
    it('should match falsy values', function()
      expect(false).to.be_falsy()
      expect(nil).to.be_falsy()
    end)

    it('should fail for truthy values', function()
      expect(function()
        expect(true).to.be_falsy()
      end).to.throw()

      expect(function()
        expect(1).to.be_falsy()
      end).to.throw()
    end)
  end)

  describe('be_near', function()
    it('should match values within epsilon', function()
      expect(1.0).to.be_near(1.01, 0.1)
      expect(1.0).to.be_near(0.99, 0.1)
    end)

    it('should fail when difference exceeds epsilon', function()
      expect(function()
        expect(1.0).to.be_near(2.0, 0.1)
      end).to.throw()
    end)
  end)

  describe('be_positive', function()
    it('should match positive numbers', function()
      expect(1).to.be_positive()
      expect(100).to.be_positive()
      expect(0.01).to.be_positive()
    end)

    it('should fail for zero', function()
      expect(function()
        expect(0).to.be_positive()
      end).to.throw()
    end)

    it('should fail for negative numbers', function()
      expect(function()
        expect(-1).to.be_positive()
      end).to.throw()
    end)
  end)

  describe('be_negative', function()
    it('should match negative numbers', function()
      expect(-1).to.be_negative()
      expect(-100).to.be_negative()
      expect(-0.01).to.be_negative()
    end)

    it('should fail for zero', function()
      expect(function()
        expect(0).to.be_negative()
      end).to.throw()
    end)

    it('should fail for positive numbers', function()
      expect(function()
        expect(1).to.be_negative()
      end).to.throw()
    end)
  end)

  describe('be_between', function()
    it('should match values in range (inclusive)', function()
      expect(5).to.be_between(1, 10)
      expect(1).to.be_between(1, 10)
      expect(10).to.be_between(1, 10)
    end)

    it('should fail for values outside range', function()
      expect(function()
        expect(0).to.be_between(1, 10)
      end).to.throw()

      expect(function()
        expect(11).to.be_between(1, 10)
      end).to.throw()
    end)
  end)

  describe('be_nan', function()
    it('should match NaN values', function()
      local nan = 0/0
      expect(nan).to.be_nan()
    end)

    it('should fail for non-NaN values', function()
      expect(function()
        expect(5).to.be_nan()
      end).to.throw()
    end)
  end)

  describe('contain (string)', function()
    it('should match when string contains substring', function()
      expect('hello world').to.contain('world')
      expect('hello world').to.contain('hello')
    end)

    it('should fail when substring not found', function()
      expect(function()
        expect('hello world').to.contain('foo')
      end).to.throw()
    end)

    it('should fail for non-strings', function()
      expect(function()
        expect(123).to.contain('1')
      end).to.throw()
    end)
  end)

  describe('match_pattern', function()
    it('should match strings against patterns', function()
      expect('hello123').to.match_pattern('%a+%d+')
      expect('test@example.com').to.match_pattern('@')
    end)

    it('should fail when pattern does not match', function()
      expect(function()
        expect('hello').to.match_pattern('%d+')
      end).to.throw()
    end)
  end)

  describe('start_with', function()
    it('should match strings starting with prefix', function()
      expect('hello world').to.start_with('hello')
      expect('test').to.start_with('te')
    end)

    it('should fail when string does not start with prefix', function()
      expect(function()
        expect('hello world').to.start_with('world')
      end).to.throw()
    end)
  end)

  describe('end_with', function()
    it('should match strings ending with suffix', function()
      expect('hello world').to.end_with('world')
      expect('test').to.end_with('st')
    end)

    it('should fail when string does not end with suffix', function()
      expect(function()
        expect('hello world').to.end_with('hello')
      end).to.throw()
    end)
  end)

  describe('have_length', function()
    it('should match strings with specific length', function()
      expect('hello').to.have_length(5)
      expect('').to.have_length(0)
    end)

    it('should fail for wrong length', function()
      expect(function()
        expect('hello').to.have_length(10)
      end).to.throw()
    end)
  end)

  describe('be_empty', function()
    it('should match empty strings', function()
      expect('').to.be_empty()
    end)

    it('should match empty tables', function()
      expect({}).to.be_empty()
    end)

    it('should fail for non-empty values', function()
      expect(function()
        expect('hello').to.be_empty()
      end).to.throw()

      expect(function()
        expect({1}).to.be_empty()
      end).to.throw()
    end)
  end)

  describe('have_size', function()
    it('should match tables with specific size', function()
      expect({a=1, b=2, c=3}).to.have_size(3)
      expect({}).to.have_size(0)
    end)

    it('should fail for wrong size', function()
      expect(function()
        expect({a=1, b=2}).to.have_size(5)
      end).to.throw()
    end)
  end)

  describe('contain_element', function()
    it('should match when table contains element', function()
      expect({1, 2, 3}).to.contain_element(2)
      expect({a='x', b='y'}).to.contain_element('y')
    end)

    it('should fail when element not found', function()
      expect(function()
        expect({1, 2, 3}).to.contain_element(5)
      end).to.throw()
    end)
  end)

  describe('be_of_type', function()
    it('should match correct types', function()
      expect('hello').to.be_of_type('string')
      expect(42).to.be_of_type('number')
      expect({}).to.be_of_type('table')
      expect(function() end).to.be_of_type('function')
    end)

    it('should fail for wrong types', function()
      expect(function()
        expect('hello').to.be_of_type('number')
      end).to.throw()
    end)
  end)

  describe('all_of', function()
    it('should pass when all matchers pass', function()
      expect(10).to.match(matchers.all_of(
        matchers.greater_than(5),
        matchers.less_than(20),
        matchers.is_positive()
      ))
    end)

    it('should fail when any matcher fails', function()
      expect(function()
        expect(10).to.match(matchers.all_of(
          matchers.greater_than(5),
          matchers.less_than(8)
        ))
      end).to.throw()
    end)
  end)

  describe('any_of', function()
    it('should pass when any matcher passes', function()
      expect(10).to.match(matchers.any_of(
        matchers.equals(5),
        matchers.equals(10),
        matchers.equals(15)
      ))
    end)

    it('should fail when no matchers pass', function()
      expect(function()
        expect(10).to.match(matchers.any_of(
          matchers.equals(5),
          matchers.equals(15)
        ))
      end).to.throw()
    end)
  end)

  describe('none_of', function()
    it('should pass when no matchers pass', function()
      expect(5).to.match(matchers.none_of(
        matchers.equals(1),
        matchers.equals(2),
        matchers.equals(3)
      ))
    end)

    it('should fail when any matcher passes', function()
      expect(function()
        expect(2).to.match(matchers.none_of(
          matchers.equals(1),
          matchers.equals(2),
          matchers.equals(3)
        ))
      end).to.throw()
    end)
  end)

  describe('be_instance_of', function()
    it('should check if value is instance of class', function()
      local MyClass = llx.class 'MyClass' {
        __init = function(self, value)
          self.value = value
        end
      }

      local instance = MyClass(42)

      expect(instance).to.be_instance_of(MyClass)
    end)

    it('should fail for non-instance', function()
      local MyClass = llx.class 'MyClass' {}
      local OtherClass = llx.class 'OtherClass' {}

      local instance = OtherClass()

      expect(function()
        expect(instance).to.be_instance_of(MyClass)
      end).to.throw()
    end)
  end)

  describe('match_table', function()
    it('should deeply compare tables', function()
      local table1 = {a = 1, b = {c = 2, d = 3}}
      local table2 = {a = 1, b = {c = 2, d = 3}}

      expect(table1).to.match_table(table2)
    end)

    it('should fail for different tables', function()
      local table1 = {a = 1, b = 2}
      local table2 = {a = 1, b = 3}

      expect(function()
        expect(table1).to.match_table(table2)
      end).to.throw()
    end)

    it('should handle nested tables', function()
      local table1 = {a = {b = {c = {d = 1}}}}
      local table2 = {a = {b = {c = {d = 1}}}}

      expect(table1).to.match_table(table2)
    end)

    it('should detect extra keys', function()
      local table1 = {a = 1}
      local table2 = {a = 1, b = 2}

      expect(function()
        expect(table1).to.match_table(table2)
      end).to.throw()
    end)
  end)

  describe('have_property', function()
    it('should check if object has property', function()
      local obj = {name = 'Alice', age = 30}

      expect(obj).to.have_property('name')
    end)

    it('should check property value', function()
      local obj = {name = 'Alice', age = 30}

      expect(obj).to.have_property('name', 'Alice')
    end)

    it('should fail if property missing', function()
      local obj = {name = 'Alice'}

      expect(function()
        expect(obj).to.have_property('age')
      end).to.throw()
    end)

    it('should fail if property value does not match', function()
      local obj = {name = 'Alice', age = 30}

      expect(function()
        expect(obj).to.have_property('age', 25)
      end).to.throw()
    end)
  end)

  describe('respond_to', function()
    it('should check if object has method', function()
      local obj = {
        greet = function(self) return 'Hello' end
      }

      expect(obj).to.respond_to('greet')
    end)

    it('should fail if method missing', function()
      local obj = {}

      expect(function()
        expect(obj).to.respond_to('greet')
      end).to.throw()
    end)

    it('should work with classes', function()
      local MyClass = llx.class 'MyClass' {
        greet = function(self) return 'Hello' end
      }

      local instance = MyClass()

      expect(instance).to.respond_to('greet')
    end)

    it('should fail for non-callable properties', function()
      local obj = {name = 'Alice'}

      expect(function()
        expect(obj).to.respond_to('name')
      end).to.throw()
    end)
  end)

  describe('be_a', function()
    it('should check type', function()
      expect('hello').to.be_a('string')
      expect(42).to.be_a('number')
      expect({}).to.be_a('table')
      expect(function() end).to.be_a('function')
      expect(true).to.be_a('boolean')
      expect(nil).to.be_a('nil')
    end)

    it('should fail for wrong type', function()
      expect(function()
        expect('hello').to.be_a('number')
      end).to.throw()
    end)
  end)

  describe('have_keys', function()
    it('should check if table has all keys', function()
      local obj = {a = 1, b = 2, c = 3}

      expect(obj).to.have_keys('a', 'b', 'c')
    end)

    it('should pass with subset of keys', function()
      local obj = {a = 1, b = 2, c = 3, d = 4}

      expect(obj).to.have_keys('a', 'b')
    end)

    it('should fail if any key is missing', function()
      local obj = {a = 1, b = 2}

      expect(function()
        expect(obj).to.have_keys('a', 'b', 'c')
      end).to.throw()
    end)
  end)

  describe('be_even', function()
    it('should check if number is even', function()
      expect(2).to.be_even()
      expect(4).to.be_even()
      expect(100).to.be_even()
      expect(0).to.be_even()
    end)

    it('should fail for odd numbers', function()
      expect(function()
        expect(3).to.be_even()
      end).to.throw()
    end)

    it('should fail for non-numbers', function()
      expect(function()
        expect('hello').to.be_even()
      end).to.throw()
    end)
  end)

  describe('be_odd', function()
    it('should check if number is odd', function()
      expect(1).to.be_odd()
      expect(3).to.be_odd()
      expect(99).to.be_odd()
    end)

    it('should fail for even numbers', function()
      expect(function()
        expect(2).to.be_odd()
      end).to.throw()
    end)

    it('should fail for non-numbers', function()
      expect(function()
        expect('hello').to.be_odd()
      end).to.throw()
    end)
  end)

  describe('matcher negation', function()
    it('should work with to_not', function()
      expect(3).to_not.be_even()
      expect(2).to_not.be_odd()
      expect('hello').to_not.be_equal_to('world')
      expect(5).to_not.be_greater_than(10)
    end)

    it('should work with complex matchers', function()
      local obj1 = {a = 1}
      local obj2 = {a = 2}

      expect(obj1).to_not.match_table(obj2)
    end)
  end)
end)
