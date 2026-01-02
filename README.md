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
    expect(2 + 2).to.be_equal_to(4)
  end)

  it('should work with mocks', function()
    local mock = Mock()
    mock:mockReturnValue(42)
    expect(mock()).to.be_equal_to(42)
    expect(mock).to.have_been_called_times(1)
  end)
end)

-- Run tests
unit.run_unit_tests()
```

---

## Assertions

The framework uses an `expect()` API with matchers:

```lua
expect(actual).to.be_equal_to(expected)
expect(actual).to.be_greater_than(value)
expect(actual).to.contain(substring)
expect(actual).toNot.be_nil()
```

---

## Matchers

Built-in matchers available via `expect().to.*`:

| Matcher | Description |
| ------- | ----------- |
| `be_equal_to(value)` | Checks equality |
| `be_greater_than(value)` | `>` comparison |
| `be_less_than(value)` | `<` comparison |
| `be_greater_than_or_equal(value)` | `>=` comparison |
| `be_less_than_or_equal(value)` | `<=` comparison |
| `be_near(value, epsilon)` | Floating point comparison |
| `be_nil()` | Checks for nil |
| `be_truthy()` | Checks if value is truthy |
| `be_falsy()` | Checks if value is falsy |
| `contain(substring)` | String contains substring |
| `match_pattern(pattern)` | String matches pattern |
| `be_empty()` | Collection is empty |
| `have_size(n)` | Collection has size n |
| `contain_element(element)` | Collection contains element |
| `be_of_type(type)` | Checks class/type |
| `be_positive()` | Number > 0 |
| `be_negative()` | Number < 0 |
| `be_between(min, max)` | Number in range |
| `be_nan()` | Checks for NaN |

---

## Mocks

Mocks provide flexible call tracking and behavior control.

### Basic Usage

```lua
local mock = Mock()
mock:mockReturnValue(42)
local result = mock('hello', 'world')
expect(mock).to.have_been_called_times(1)
expect(mock).to.have_been_called_with('hello', 'world')
```

### Return Values

```lua
local mock = Mock()

-- Set default return value for all calls
mock:mockReturnValue(100)
expect(mock()).to.be_equal_to(100)
expect(mock()).to.be_equal_to(100)

-- Set return value for next call only
mock:mockReturnValueOnce(1):mockReturnValueOnce(2)
expect(mock()).to.be_equal_to(1)
expect(mock()).to.be_equal_to(2)
expect(mock()).to.be_equal_to(100) -- Falls back to default
```

### Custom Implementations

```lua
local mock = Mock()

-- Set default implementation
mock:mockImplementation(function(x, y)
  return x + y
end)
expect(mock(2, 3)).to.be_equal_to(5)

-- Set implementation for next call only
mock:mockImplementationOnce(function(x) return x * 2 end)
expect(mock(5)).to.be_equal_to(10)
expect(mock(5)).to.be_equal_to(5) -- Falls back to default
```

### Call History

```lua
local mock = Mock()
mock('first', 1)
mock('second', 2)

expect(mock:get_call_count()).to.be_equal_to(2)
expect(mock:get_last_call().args[1]).to.be_equal_to('second')
expect(mock:get_call(1).args[1]).to.be_equal_to('first')
```

### Mock Matchers

```lua
local mock = Mock()
mock('hello', 'world')

expect(mock).to.have_been_called()
expect(mock).to.have_been_called_times(1)
expect(mock).to.have_been_called_with('hello', 'world')
expect(mock).to.have_been_last_called_with('hello', 'world')
expect(mock).to.have_been_nth_called_with(1, 'hello', 'world')
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

expect(result).to.be_equal_to(5) -- Original still works
expect(spy).to.have_been_called_times(1)

-- Override behavior
spy:mockReturnValue(999)
expect(obj.method(1, 1)).to.be_equal_to(999)

-- Restore original
spy:mockRestore()
expect(obj.method(2, 3)).to.be_equal_to(5)
```

### State Management

```lua
local mock = Mock()
mock:mockReturnValue(42)
mock()
mock()

-- Clear call history but keep implementation
mock:mockClear()
expect(mock:get_call_count()).to.be_equal_to(0)
expect(mock()).to.be_equal_to(42) -- Still works

-- Reset everything
mock:mockReset()
expect(mock()).to.be_nil() -- Everything reset
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
    expect(true).to.be_truthy()
  end)
  
  -- Nested suites
  describe('Nested Suite', function()
    it('should work', function()
      expect(1 + 1).to.be_equal_to(2)
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
