-- test_mock.lua
-- Tests for the new Mock implementation

local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

describe('Mock', function()
  it('should track call count', function()
    local mock = Mock()
    expect(mock:get_call_count()).to.be_equal_to(0)
    
    mock()
    expect(mock:get_call_count()).to.be_equal_to(1)
    
    mock()
    mock()
    expect(mock:get_call_count()).to.be_equal_to(3)
  end)

  it('should return nil by default', function()
    local mock = Mock()
    local result = mock()
    expect(result).to.be_nil()
  end)

  it('should return default value when mockReturnValue is set', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    expect(mock()).to.be_equal_to(42)
    expect(mock()).to.be_equal_to(42)
    expect(mock()).to.be_equal_to(42)
  end)

  it('should return queued values when mockReturnValueOnce is used', function()
    local mock = Mock()
    mock:mockReturnValueOnce(1):mockReturnValueOnce(2):mockReturnValueOnce(3)
    expect(mock()).to.be_equal_to(1)
    expect(mock()).to.be_equal_to(2)
    expect(mock()).to.be_equal_to(3)
    expect(mock()).to.be_nil() -- Queue exhausted
  end)

  it('should use queued values before default value', function()
    local mock = Mock()
    mock:mockReturnValue(100)
    mock:mockReturnValueOnce(1):mockReturnValueOnce(2)
    expect(mock()).to.be_equal_to(1)
    expect(mock()).to.be_equal_to(2)
    expect(mock()).to.be_equal_to(100) -- Falls back to default
    expect(mock()).to.be_equal_to(100)
  end)

  it('should use custom implementation when mockImplementation is set', function()
    local mock = Mock()
    mock:mockImplementation(function(x, y)
      return x + y
    end)
    expect(mock(2, 3)).to.be_equal_to(5)
    expect(mock(10, 20)).to.be_equal_to(30)
  end)

  it('should use queued implementation when mockImplementationOnce is used', function()
    local mock = Mock()
    mock:mockImplementationOnce(function(x) return x * 2 end)
    mock:mockImplementationOnce(function(x) return x * 3 end)
    expect(mock(5)).to.be_equal_to(10)
    expect(mock(5)).to.be_equal_to(15)
    expect(mock(5)).to.be_nil() -- Queue exhausted, no default
  end)

  it('should prioritize implementation over return value', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    mock:mockImplementation(function() return 100 end)
    expect(mock()).to.be_equal_to(100) -- Implementation takes priority
  end)

  it('should track call history', function()
    local mock = Mock()
    mock('hello', 'world')
    mock('foo')
    
    local calls = mock:get_calls()
    expect(#calls).to.be_equal_to(2)
    expect(calls[1].args[1]).to.be_equal_to('hello')
    expect(calls[1].args[2]).to.be_equal_to('world')
    expect(calls[2].args[1]).to.be_equal_to('foo')
  end)

  it('should get specific call by index', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    local call = mock:get_call(2)
    expect(call.args[1]).to.be_equal_to('second')
  end)

  it('should get last call', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    local last = mock:get_last_call()
    expect(last.args[1]).to.be_equal_to('third')
  end)

  it('should clear call history with mockClear', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    mock()
    mock()
    expect(mock:get_call_count()).to.be_equal_to(2)
    
    mock:mockClear()
    expect(mock:get_call_count()).to.be_equal_to(0)
    expect(mock()).to.be_equal_to(42) -- Implementation still works
  end)

  it('should reset everything with mockReset', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    mock:mockImplementation(function() return 100 end)
    mock()
    
    mock:mockReset()
    expect(mock:get_call_count()).to.be_equal_to(0)
    expect(mock()).to.be_nil() -- Everything reset
  end)

  it('should support constructor with default return value', function()
    local mock = Mock(99)
    expect(mock()).to.be_equal_to(99)
    expect(mock()).to.be_equal_to(99)
  end)

  it('should support have_been_called matcher', function()
    local mock = Mock()
    expect(mock).toNot.have_been_called()
    
    mock()
    expect(mock).to.have_been_called()
  end)

  it('should support have_been_called_times matcher', function()
    local mock = Mock()
    expect(mock).to.have_been_called_times(0)
    
    mock()
    expect(mock).to.have_been_called_times(1)
    
    mock()
    mock()
    expect(mock).to.have_been_called_times(3)
  end)

  it('should support have_been_called_with matcher', function()
    local mock = Mock()
    mock('hello', 'world')
    mock('foo')
    
    expect(mock).to.have_been_called_with('hello', 'world')
    expect(mock).to.have_been_called_with('foo')
    expect(mock).toNot.have_been_called_with('bar')
  end)

  it('should support have_been_called_with with matchers', function()
    local mock = Mock()
    mock(42, 'hello world')
    
    expect(mock).to.have_been_called_with(Equals(42), StartsWith('hello'))
    expect(mock).to.have_been_called_with(42, Contains('world'))
  end)

  it('should support have_been_last_called_with matcher', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    expect(mock).to.have_been_last_called_with('third')
    expect(mock).toNot.have_been_last_called_with('first')
  end)

  it('should support have_been_nth_called_with matcher', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    expect(mock).to.have_been_nth_called_with(1, 'first')
    expect(mock).to.have_been_nth_called_with(2, 'second')
    expect(mock).to.have_been_nth_called_with(3, 'third')
    expect(mock).toNot.have_been_nth_called_with(1, 'wrong')
  end)

  it('should support multiple return values', function()
    local mock = Mock()
    mock:mockReturnValue(1, 2, 3)
    local a, b, c = mock()
    expect(a).to.be_equal_to(1)
    expect(b).to.be_equal_to(2)
    expect(c).to.be_equal_to(3)
  end)

  it('should support multiple return values in queue', function()
    local mock = Mock()
    mock:mockReturnValueOnce(1, 2)
    mock:mockReturnValueOnce(3, 4)
    local a1, b1 = mock()
    local a2, b2 = mock()
    expect(a1).to.be_equal_to(1)
    expect(b1).to.be_equal_to(2)
    expect(a2).to.be_equal_to(3)
    expect(b2).to.be_equal_to(4)
  end)

  describe('Argument type handling', function()
    it('should handle numeric arguments in have_been_called_with', function()
      local mock = Mock()
      mock(42, 100, 3.14)
      
      expect(mock).to.have_been_called_with(42, 100, 3.14)
      expect(mock).toNot.have_been_called_with(1, 2, 3)
    end)

    it('should handle nil arguments in have_been_called_with', function()
      local mock = Mock()
      mock(nil, 'hello', nil)
      
      expect(mock).to.have_been_called_with(nil, 'hello', nil)
      expect(mock).toNot.have_been_called_with('hello', nil, 'world')
    end)

    it('should handle matcher functions in have_been_called_with error messages', function()
      local mock = Mock()
      mock(42, 'hello world')
      
      -- This should work without crashing
      expect(mock).to.have_been_called_with(Equals(42), StartsWith('hello'))
      
      -- Test error message when it fails
      local success, err = pcall(function()
        expect(mock).to.have_been_called_with(Equals(99), StartsWith('goodbye'))
      end)
      expect(success).to.be_equal_to(false)
      -- Error message should contain '<matcher>' instead of function object
      expect(err).to.contain('<matcher>')
    end)

    it('should handle mixed types in have_been_last_called_with', function()
      local mock = Mock()
      mock('first', 1)
      mock('second', 2, true, nil)
      
      expect(mock).to.have_been_last_called_with('second', 2, true, nil)
      
      -- Test error message formatting
      local success, err = pcall(function()
        expect(mock).to.have_been_last_called_with('wrong', 99)
      end)
      expect(success).to.be_equal_to(false)
      expect(err).to.contain('last call was with')
    end)

    it('should handle matchers in have_been_nth_called_with error messages', function()
      local mock = Mock()
      mock('first', 1)
      mock('second', 2)
      mock('third', 3)
      
      expect(mock).to.have_been_nth_called_with(2, 'second', 2)
      
      -- Test error message when it fails
      local success, err = pcall(function()
        expect(mock).to.have_been_nth_called_with(1, Equals('wrong'), GreaterThan(100))
      end)
      expect(success).to.be_equal_to(false)
      -- Error message should contain '<matcher>' instead of function object
      expect(err).to.contain('<matcher>')
    end)
  end)

  describe('Nil argument handling', function()
    it('should correctly match nil values', function()
      local mock = Mock()
      mock(nil, 'hello', nil)
      
      expect(mock).to.have_been_called_with(nil, 'hello', nil)
      expect(mock).toNot.have_been_called_with('hello', nil, 'world')
    end)

    it('should correctly distinguish nil from non-nil', function()
      local mock = Mock()
      mock('hello', nil, 'world')
      
      -- Should match when nil is in the same position
      expect(mock).to.have_been_called_with('hello', nil, 'world')
      -- Should not match when a non-nil value is in the nil position
      expect(mock).toNot.have_been_called_with('hello', 'notnil', 'world')
      -- Should not match when first arg is different
      expect(mock).toNot.have_been_called_with('goodbye', nil, 'world')
    end)

    it('should work with matchers and nil', function()
      local mock = Mock()
      mock(nil, 42, 'test')
      
      -- Should match when nil and matchers match
      expect(mock).to.have_been_called_with(nil, Equals(42), StartsWith('te'))
      -- Should not match when nil position has a value
      expect(mock).toNot.have_been_called_with('notnil', Equals(42), StartsWith('te'))
      -- Should match when all matchers pass
      expect(mock).to.have_been_called_with(nil, GreaterThan(40), Contains('te'))
      
      -- Test with nil in different positions
      local mock2 = Mock()
      mock2(42, nil, 'test')
      expect(mock2).to.have_been_called_with(Equals(42), nil, StartsWith('te'))
      expect(mock2).toNot.have_been_called_with(Equals(99), nil, StartsWith('te'))
    end)
  end)

  describe('have_been_nth_called_with validation', function()
    it('should accept valid positive integers', function()
      local mock = Mock()
      mock('first')
      mock('second')
      mock('third')
      
      expect(mock).to.have_been_nth_called_with(1, 'first')
      expect(mock).to.have_been_nth_called_with(2, 'second')
      expect(mock).to.have_been_nth_called_with(3, 'third')
    end)

    it('should reject non-integer values', function()
      local mock = Mock()
      mock('test')
      
      local success, err = pcall(function()
        expect(mock).to.have_been_nth_called_with(1.5, 'test')
      end)
      expect(success).to.be_equal_to(false)
      expect(err).to.contain('positive integer')
      
      success, err = pcall(function()
        expect(mock).to.have_been_nth_called_with('1', 'test')
      end)
      expect(success).to.be_equal_to(false)
      expect(err).to.contain('positive integer')
    end)

    it('should reject zero and negative numbers', function()
      local mock = Mock()
      mock('test')
      
      local success, err = pcall(function()
        expect(mock).to.have_been_nth_called_with(0, 'test')
      end)
      expect(success).to.be_equal_to(false)
      expect(err).to.contain('positive integer')
      
      success, err = pcall(function()
        expect(mock).to.have_been_nth_called_with(-1, 'test')
      end)
      expect(success).to.be_equal_to(false)
      expect(err).to.contain('positive integer')
    end)
  end)

  describe('Error message formatting', function()
    it('should format matcher error messages clearly', function()
      local mock = Mock()
      mock(42, 'hello')
      
      -- When using matchers, error messages should be readable
      local success, err = pcall(function()
        expect(mock).to.have_been_called_with(Equals(99), StartsWith('goodbye'))
      end)
      expect(success).to.be_equal_to(false)
      -- Should not contain function object representations
      expect(err).toNot.contain('function:')
      expect(err).to.contain('arguments matching')
    end)

    it('should format last call error messages with proper types', function()
      local mock = Mock()
      mock(1, 2, 3)
      mock('a', 'b', true, nil)
      
      local success, err = pcall(function()
        expect(mock).to.have_been_last_called_with('wrong', 99)
      end)
      expect(success).to.be_equal_to(false)
      -- Error should show the actual call arguments properly formatted
      expect(err).to.contain('last call was with')
      expect(err).to.contain('a')
      expect(err).to.contain('b')
    end)
  end)
end)

describe('spyOn', function()
  it('should spy on existing object method', function()
    local obj = {
      method = function(x, y)
        return x + y
      end
    }
    
    local spy = spyOn(obj, 'method')
    local result = obj.method(2, 3)
    
    expect(result).to.be_equal_to(5) -- Original still works
    expect(spy).to.have_been_called_times(1)
    expect(spy).to.have_been_called_with(2, 3)
  end)

  it('should track calls to spied method', function()
    local obj = {
      counter = 0,
      increment = function(self)
        self.counter = self.counter + 1
        return self.counter
      end
    }
    
    local spy = spyOn(obj, 'increment')
    obj:increment()
    obj:increment()
    
    expect(spy).to.have_been_called_times(2)
    expect(obj.counter).to.be_equal_to(2) -- Original still works
  end)

  it('should allow overriding spy implementation', function()
    local obj = {
      method = function(x)
        return x * 2
      end
    }
    
    local spy = spyOn(obj, 'method')
    spy:mockReturnValue(999)
    
    expect(obj.method(5)).to.be_equal_to(999) -- Overridden
    expect(spy).to.have_been_called_times(1)
    expect(spy).to.have_been_called_with(5)
  end)

  it('should restore original method when mockRestore is called', function()
    local obj = {
      method = function(x)
        return x * 2
      end
    }
    
    local original = obj.method
    local spy = spyOn(obj, 'method')
    spy:mockReturnValue(999)
    
    expect(obj.method(5)).to.be_equal_to(999)
    
    spy:mockRestore()
    expect(obj.method(5)).to.be_equal_to(10) -- Original restored
    expect(obj.method).to.be_equal_to(original)
  end)

  it('should throw error when spying on non-existent method', function()
    local obj = {}
    expect(function()
      spyOn(obj, 'nonexistent')
    end).to.throw()
  end)

  it('should throw error when spying on non-function', function()
    local obj = {
      not_a_function = 42
    }
    expect(function()
      spyOn(obj, 'not_a_function')
    end).to.throw()
  end)
end)

run_unit_tests()

