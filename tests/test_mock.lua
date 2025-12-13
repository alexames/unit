-- test_mock.lua
-- Tests for the new Mock implementation

local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

describe('Mock', function()
  it('should track call count', function()
    local mock = Mock()
    expect(mock:get_call_count()).to.beEqualTo(0)
    
    mock()
    expect(mock:get_call_count()).to.beEqualTo(1)
    
    mock()
    mock()
    expect(mock:get_call_count()).to.beEqualTo(3)
  end)

  it('should return nil by default', function()
    local mock = Mock()
    local result = mock()
    expect(result).to.beNil()
  end)

  it('should return default value when mockReturnValue is set', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    expect(mock()).to.beEqualTo(42)
    expect(mock()).to.beEqualTo(42)
    expect(mock()).to.beEqualTo(42)
  end)

  it('should return queued values when mockReturnValueOnce is used', function()
    local mock = Mock()
    mock:mockReturnValueOnce(1):mockReturnValueOnce(2):mockReturnValueOnce(3)
    expect(mock()).to.beEqualTo(1)
    expect(mock()).to.beEqualTo(2)
    expect(mock()).to.beEqualTo(3)
    expect(mock()).to.beNil() -- Queue exhausted
  end)

  it('should use queued values before default value', function()
    local mock = Mock()
    mock:mockReturnValue(100)
    mock:mockReturnValueOnce(1):mockReturnValueOnce(2)
    expect(mock()).to.beEqualTo(1)
    expect(mock()).to.beEqualTo(2)
    expect(mock()).to.beEqualTo(100) -- Falls back to default
    expect(mock()).to.beEqualTo(100)
  end)

  it('should use custom implementation when mockImplementation is set', function()
    local mock = Mock()
    mock:mockImplementation(function(x, y)
      return x + y
    end)
    expect(mock(2, 3)).to.beEqualTo(5)
    expect(mock(10, 20)).to.beEqualTo(30)
  end)

  it('should use queued implementation when mockImplementationOnce is used', function()
    local mock = Mock()
    mock:mockImplementationOnce(function(x) return x * 2 end)
    mock:mockImplementationOnce(function(x) return x * 3 end)
    expect(mock(5)).to.beEqualTo(10)
    expect(mock(5)).to.beEqualTo(15)
    expect(mock(5)).to.beNil() -- Queue exhausted, no default
  end)

  it('should prioritize implementation over return value', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    mock:mockImplementation(function() return 100 end)
    expect(mock()).to.beEqualTo(100) -- Implementation takes priority
  end)

  it('should track call history', function()
    local mock = Mock()
    mock('hello', 'world')
    mock('foo')
    
    local calls = mock:get_calls()
    expect(#calls).to.beEqualTo(2)
    expect(calls[1].args[1]).to.beEqualTo('hello')
    expect(calls[1].args[2]).to.beEqualTo('world')
    expect(calls[2].args[1]).to.beEqualTo('foo')
  end)

  it('should get specific call by index', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    local call = mock:get_call(2)
    expect(call.args[1]).to.beEqualTo('second')
  end)

  it('should get last call', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    local last = mock:get_last_call()
    expect(last.args[1]).to.beEqualTo('third')
  end)

  it('should clear call history with mockClear', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    mock()
    mock()
    expect(mock:get_call_count()).to.beEqualTo(2)
    
    mock:mockClear()
    expect(mock:get_call_count()).to.beEqualTo(0)
    expect(mock()).to.beEqualTo(42) -- Implementation still works
  end)

  it('should reset everything with mockReset', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    mock:mockImplementation(function() return 100 end)
    mock()
    
    mock:mockReset()
    expect(mock:get_call_count()).to.beEqualTo(0)
    expect(mock()).to.beNil() -- Everything reset
  end)

  it('should support constructor with default return value', function()
    local mock = Mock(99)
    expect(mock()).to.beEqualTo(99)
    expect(mock()).to.beEqualTo(99)
  end)

  it('should support toHaveBeenCalled matcher', function()
    local mock = Mock()
    expect(mock).toNot.toHaveBeenCalled()
    
    mock()
    expect(mock).to.toHaveBeenCalled()
  end)

  it('should support toHaveBeenCalledTimes matcher', function()
    local mock = Mock()
    expect(mock).to.toHaveBeenCalledTimes(0)
    
    mock()
    expect(mock).to.toHaveBeenCalledTimes(1)
    
    mock()
    mock()
    expect(mock).to.toHaveBeenCalledTimes(3)
  end)

  it('should support toHaveBeenCalledWith matcher', function()
    local mock = Mock()
    mock('hello', 'world')
    mock('foo')
    
    expect(mock).to.toHaveBeenCalledWith('hello', 'world')
    expect(mock).to.toHaveBeenCalledWith('foo')
    expect(mock).toNot.toHaveBeenCalledWith('bar')
  end)

  it('should support toHaveBeenCalledWith with matchers', function()
    local mock = Mock()
    mock(42, 'hello world')
    
    expect(mock).to.toHaveBeenCalledWith(Equals(42), StartsWith('hello'))
    expect(mock).to.toHaveBeenCalledWith(42, Contains('world'))
  end)

  it('should support toHaveBeenLastCalledWith matcher', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    expect(mock).to.toHaveBeenLastCalledWith('third')
    expect(mock).toNot.toHaveBeenLastCalledWith('first')
  end)

  it('should support toHaveBeenNthCalledWith matcher', function()
    local mock = Mock()
    mock('first')
    mock('second')
    mock('third')
    
    expect(mock).to.toHaveBeenNthCalledWith(1, 'first')
    expect(mock).to.toHaveBeenNthCalledWith(2, 'second')
    expect(mock).to.toHaveBeenNthCalledWith(3, 'third')
    expect(mock).toNot.toHaveBeenNthCalledWith(1, 'wrong')
  end)

  it('should support multiple return values', function()
    local mock = Mock()
    mock:mockReturnValue(1, 2, 3)
    local a, b, c = mock()
    expect(a).to.beEqualTo(1)
    expect(b).to.beEqualTo(2)
    expect(c).to.beEqualTo(3)
  end)

  it('should support multiple return values in queue', function()
    local mock = Mock()
    mock:mockReturnValueOnce(1, 2)
    mock:mockReturnValueOnce(3, 4)
    local a1, b1 = mock()
    local a2, b2 = mock()
    expect(a1).to.beEqualTo(1)
    expect(b1).to.beEqualTo(2)
    expect(a2).to.beEqualTo(3)
    expect(b2).to.beEqualTo(4)
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
    
    expect(result).to.beEqualTo(5) -- Original still works
    expect(spy).to.toHaveBeenCalledTimes(1)
    expect(spy).to.toHaveBeenCalledWith(2, 3)
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
    
    expect(spy).to.toHaveBeenCalledTimes(2)
    expect(obj.counter).to.beEqualTo(2) -- Original still works
  end)

  it('should allow overriding spy implementation', function()
    local obj = {
      method = function(x)
        return x * 2
      end
    }
    
    local spy = spyOn(obj, 'method')
    spy:mockReturnValue(999)
    
    expect(obj.method(5)).to.beEqualTo(999) -- Overridden
    expect(spy).to.toHaveBeenCalledTimes(1)
    expect(spy).to.toHaveBeenCalledWith(5)
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
    
    expect(obj.method(5)).to.beEqualTo(999)
    
    spy:mockRestore()
    expect(obj.method(5)).to.beEqualTo(10) -- Original restored
    expect(obj.method).to.beEqualTo(original)
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

