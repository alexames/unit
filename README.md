# Lua Unit Test Framework

A lightweight unit testing framework for Lua, inspired by GoogleTest and GoogleMock from C++.

## Features

* Google-style test classes and test naming
* Expressive assertions with custom matchers
* Flexible mocking with call expectations and argument validation
* Colored terminal output and test logging

---

## Quick Start

```lua
local unit = require 'unit'
local EXPECT_EQ = unit.EXPECT_EQ
local Equals = unit.Equals
local Mock = unit.Mock
local test_class = unit.test_class

-- Define a test class
unit.test_class 'ExampleTest' {
  ['simple addition' | test] = function()
    EXPECT_EQ(2 + 2, 4)
  end,

  ['mocked function' | test] = function()
    local mock <close> = Mock()
    mock:call_count(Equals(1)):call_spec{
      CallSpec{return_values = {42}}
    }
    EXPECT_EQ(mock(), 42)
  end,
}

-- Run tests
unit.run_unit_tests()
```

---

## Assertions

| Function                  | Description               |
| ------------------------- | ------------------------- |
| `EXPECT_EQ(a, b)`         | Asserts that `a == b`     |
| `EXPECT_NE(a, b)`         | Asserts that `a ~= b`     |
| `EXPECT_TRUE(x)`          | Asserts that `x == true`  |
| `EXPECT_FALSE(x)`         | Asserts that `x == false` |
| `EXPECT_THAT(x, matcher)` | Uses a custom matcher     |

---

## Matchers

| Matcher                  | Description                         |
| ------------------------ | ----------------------------------- |
| `Equals(expected)`       | Checks equality                     |
| `Not(predicate)`         | Negates a matcher                   |
| `GreaterThan(x)`         | `>` comparison                      |
| `LessThanOrEqual(x)`     | `<=` comparison                     |
| `StartsWith(str)`        | For string prefix                   |
| `IsOfType(type)`         | Checks class/type                   |
| `Listwise(pred, list)`   | Applies matchers element-wise       |
| `Tablewise(pred, table)` | Applies matchers to key-value pairs |

---

## Mocks

Mocks provide flexible call tracking and behavior control, similar to Jest's `jest.fn()`.

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

### Jest-style Matchers

```lua
local mock = Mock()
mock('hello', 'world')

expect(mock).to.toHaveBeenCalled()
expect(mock).to.toHaveBeenCalledTimes(1)
expect(mock).to.toHaveBeenCalledWith('hello', 'world')
expect(mock).to.toHaveBeenLastCalledWith('hello', 'world')
expect(mock).to.toHaveBeenNthCalledWith(1, 'hello', 'world')

-- With matchers
expect(mock).to.toHaveBeenCalledWith(StartsWith('hello'), Equals('world'))
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

## Test Classes

Use `test_class 'Name' { ... }` to define a suite of tests.

Each test case is registered with:

```lua
['name' | test] = function() ... end
```

Chaining `|` and `-` lets you extend test names and pass parameters (future use).

---

## Running Tests

```lua
unit.run_unit_tests()
unit.run_unit_tests("MyFilter") -- filters by class name
```

---

## Output Example

```
[==========] Running 2 tests from ExampleTest
[ Run      ] ExampleTest.simple addition
[       OK ] ExampleTest.simple addition
[ Run      ] ExampleTest.mocked function
[       OK ] ExampleTest.mocked function
[==========] All 2 tests succeeded!
```

---

## License

MIT (c) 2025
