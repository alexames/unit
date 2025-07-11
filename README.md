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

```lua
local mock <close> = Mock()
mock:call_count(Equals(2)):call_spec{
  CallSpec{return_values = {"hello"}},
  CallSpec{expected_args = {Equals(42)}, return_values = {"world"}},
}

print(mock())       -- prints: hello
print(mock(42))     -- prints: world
```

When the mock is closed (`<close>`), it automatically verifies the call count.

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
