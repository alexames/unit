# Lua Unit Test Framework

A lightweight unit testing framework for Lua with a modern describe/it API.

## Features

* Describe/it test blocks with nested suites
* Expressive assertions with custom matchers
* Flexible mocking with call expectations and argument validation
* Colored terminal output and hierarchical test logging

---

## Quick Start

```lua
local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

describe('ExampleTest', function()
  it('should add numbers correctly', function()
    expect(2 + 2).to.beEqualTo(4)
  end)

  it('should work with mocks', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    expect(mock()).to.beEqualTo(42)
    expect(mock).to.toHaveBeenCalledTimes(1)
  end)
end)

-- Run tests
unit.run_unit_tests()
```

---

## Assertions

The framework uses an `expect()` API with matchers:

```lua
expect(actual).to.beEqualTo(expected)
expect(actual).to.beGreaterThan(value)
expect(actual).to.contain(substring)
expect(actual).toNot.beNil()
```

---

## Matchers

Built-in matchers available via `expect().to.*`:

| Matcher | Description |
| ------- | ----------- |
| `beEqualTo(value)` | Checks equality |
| `beGreaterThan(value)` | `>` comparison |
| `beLessThan(value)` | `<` comparison |
| `beGreaterThanOrEqual(value)` | `>=` comparison |
| `beLessThanOrEqual(value)` | `<=` comparison |
| `beNear(value, epsilon)` | Floating point comparison |
| `beNil()` | Checks for nil |
| `beTruthy()` | Checks if value is truthy |
| `beFalsy()` | Checks if value is falsy |
| `contain(substring)` | String contains substring |
| `matchPattern(pattern)` | String matches pattern |
| `beEmpty()` | Collection is empty |
| `haveSize(n)` | Collection has size n |
| `containElement(element)` | Collection contains element |
| `beOfType(type)` | Checks class/type |
| `bePositive()` | Number > 0 |
| `beNegative()` | Number < 0 |
| `beBetween(min, max)` | Number in range |
| `beNaN()` | Checks for NaN |

---

## Mocks

Mocks provide flexible call tracking and behavior control.

### Basic Usage

```lua
local mock = Mock()
mock:mockReturnValue(42)
local result = mock('hello', 'world')
expect(mock).to.toHaveBeenCalledTimes(1)
expect(mock).to.toHaveBeenCalledWith('hello', 'world')
```

### Return Values

```lua
local mock = Mock()

-- Set default return value for all calls
mock:mockReturnValue(100)
expect(mock()).to.beEqualTo(100)
expect(mock()).to.beEqualTo(100)

-- Set return value for next call only
mock:mockReturnValueOnce(1):mockReturnValueOnce(2)
expect(mock()).to.beEqualTo(1)
expect(mock()).to.beEqualTo(2)
expect(mock()).to.beEqualTo(100) -- Falls back to default
```

### Custom Implementations

```lua
local mock = Mock()

-- Set default implementation
mock:mockImplementation(function(x, y)
  return x + y
end)
expect(mock(2, 3)).to.beEqualTo(5)

-- Set implementation for next call only
mock:mockImplementationOnce(function(x) return x * 2 end)
expect(mock(5)).to.beEqualTo(10)
expect(mock(5)).to.beEqualTo(5) -- Falls back to default
```

### Call History

```lua
local mock = Mock()
mock('first', 1)
mock('second', 2)

expect(mock:get_call_count()).to.beEqualTo(2)
expect(mock:get_last_call().args[1]).to.beEqualTo('second')
expect(mock:get_call(1).args[1]).to.beEqualTo('first')
```

### Mock Matchers

```lua
local mock = Mock()
mock('hello', 'world')

expect(mock).to.toHaveBeenCalled()
expect(mock).to.toHaveBeenCalledTimes(1)
expect(mock).to.toHaveBeenCalledWith('hello', 'world')
expect(mock).to.toHaveBeenLastCalledWith('hello', 'world')
expect(mock).to.toHaveBeenNthCalledWith(1, 'hello', 'world')
```

### Spies

```lua
local obj = {
  method = function(x, y)
    return x + y
  end
}

local spy = spyOn(obj, 'method')
local result = obj.method(2, 3)

expect(result).to.beEqualTo(5) -- Original still works
expect(spy).to.toHaveBeenCalledTimes(1)

-- Override behavior
spy:mockReturnValue(999)
expect(obj.method(1, 1)).to.beEqualTo(999)

-- Restore original
spy:mockRestore()
expect(obj.method(2, 3)).to.beEqualTo(5)
```

### State Management

```lua
local mock = Mock()
mock:mockReturnValue(42)
mock()
mock()

-- Clear call history but keep implementation
mock:mockClear()
expect(mock:get_call_count()).to.beEqualTo(0)
expect(mock()).to.beEqualTo(42) -- Still works

-- Reset everything
mock:mockReset()
expect(mock()).to.beNil() -- Everything reset
```

---

## Test Suites

Use `describe()` and `it()` to define test suites:

```lua
describe('MySuite', function()
  before_all(function()
    -- Runs once before all tests in this suite
  end)
  
  after_all(function()
    -- Runs once after all tests in this suite
  end)
  
  before_each(function()
    -- Runs before each test
  end)
  
  after_each(function()
    -- Runs after each test
  end)
  
  it('should do something', function()
    expect(true).to.beTruthy()
  end)
  
  -- Nested suites
  describe('Nested Suite', function()
    it('should work', function()
      expect(1 + 1).to.beEqualTo(2)
    end)
  end)
end)
```

---

## Running Tests

```lua
unit.run_unit_tests()
unit.run_unit_tests("MyFilter") -- filters by suite name
```

---

## Custom Matchers

You can add custom matchers:

```lua
unit.matchers.beEven = function()
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

-- Use it
expect(2).to.beEven()
```

---

## Output Example

```
+ ExampleTest
  + should add numbers correctly
  + should work with mocks

Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
+ All tests passed!
```

---

## License

MIT (c) 2025
