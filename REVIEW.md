# Code Review: Unit Testing Library

## Critical Issues

### 1. Logic Error: Unused Parameter in `expect_that`
**File:** `expects.lua:31`  
**Issue:** The function calls `predicate(actual, false)` but matcher functions only accept one parameter (`actual`). The second parameter `false` is ignored.  
**Impact:** Dead code that could cause confusion.  
**Fix:** Change line 31 from:
```lua
local result = predicate(actual, false)
```
to:
```lua
local result = predicate(actual)
```

### 2. Naming Inconsistency: `satisfyAny` vs `satisfy_any`
**File:** `test_api.lua:97` and `test_api.lua:135`  
**Issue:** Inconsistent naming - `satisfy_any` (snake_case) in `to_proxy` but `satisfyAny` (camelCase) in `to_not_proxy`.  
**Impact:** API inconsistency, users might expect `satisfy_any` to work with `toNot` but it doesn't.  
**Fix:** Standardize on one naming convention. Recommend using `satisfy_any` consistently:
- Change line 135 from `satisfyAny` to `satisfy_any`

### 3. Potential Runtime Error: `table.concat` on Non-String Values
**Files:** `test_api.lua:289, 307, 313, 316, 334, 340, 343`  
**Issue:** `table.concat()` is used on arrays that may contain non-string values (numbers, tables, functions, matchers). This will cause runtime errors.  
**Impact:** Tests using matchers or non-string arguments in mock expectations will crash.  
**Fix:** Convert values to strings before concatenation:
```lua
local function args_to_string(args)
  local str_args = {}
  for i, arg in ipairs(args) do
    if type(arg) == 'function' then
      table.insert(str_args, '<matcher>')
    else
      table.insert(str_args, tostring(arg))
    end
  end
  return table.concat(str_args, ', ')
end
```
Then use `args_to_string(expected_args)` instead of `table.concat(expected_args, ', ')`.

## Style Issues

### 4. Missing Type Validation in `contains` Matcher
**File:** `matchers.lua:285-295`  
**Issue:** The `contains` matcher only works on strings but doesn't validate the input type, leading to confusing error messages when used on non-strings.  
**Impact:** Poor user experience when misusing the matcher.  
**Fix:** Add type validation:
```lua
function contains(substring)
  return function(actual)
    if type(actual) ~= 'string' then
      return {
        pass = false,
        actual = tostring(actual) .. ' (type: ' .. type(actual) .. ')',
        positive_message = 'contain',
        negative_message = 'not contain',
        expected = 'string containing: ' .. tostring(substring)
      }
    end
    local contains = actual:find(substring, 1, true) ~= nil
    -- ... rest of function
  end
end
```

### 5. Inconsistent Error Message Formatting
**File:** `expects.lua:36`  
**Issue:** When `s` parameter is not provided, the error message starts with "expected \n" which looks odd.  
**Impact:** Minor - error messages could be cleaner.  
**Fix:** Improve formatting:
```lua
if not result.pass then
  local prefix = s and ('expected ' .. s .. '\n  ') or 'expected '
  error(prefix .. result.actual .. '\nto ' .. result.positive_message .. '\n  ' .. result.expected, level)
end
```

## Architectural Issues

### 6. Error Messages Don't Handle Matchers Well
**File:** `test_api.lua:266-346` (mock matchers)  
**Issue:** When using matchers in `toHaveBeenCalledWith`, error messages show function objects instead of meaningful descriptions.  
**Impact:** Difficult to debug test failures when using matchers.  
**Fix:** Create a helper function to format expected arguments:
```lua
local function format_expected_args(args)
  local formatted = {}
  for _, arg in ipairs(args) do
    if type(arg) == 'function' then
      table.insert(formatted, '<matcher>')
    else
      table.insert(formatted, tostring(arg))
    end
  end
  return table.concat(formatted, ', ')
end
```

### 7. Missing Nil Handling Documentation
**File:** `test_api.lua:207-231` (`match_args` function)  
**Issue:** The function handles nil values implicitly but doesn't document this behavior clearly.  
**Impact:** Edge cases might be confusing.  
**Fix:** Add explicit nil handling and comments:
```lua
local function match_args(actual_args, expected_args)
  if #actual_args ~= #expected_args then
    return false
  end
  
  for i, expected in ipairs(expected_args) do
    local actual = actual_args[i]
    
    -- Handle nil values explicitly
    if expected == nil and actual ~= nil then
      return false
    elseif expected ~= nil and actual == nil then
      return false
    elseif expected == nil and actual == nil then
      -- Both nil, continue
    -- If expected is a matcher function, use it
    elseif type(expected) == 'function' then
      -- ... existing matcher logic
    -- Otherwise do direct equality check
    elseif actual ~= expected then
      return false
    end
  end
  
  return true
end
```

## Minor Issues

### 8. Inconsistent Return Value Handling
**File:** `mock.lua:173`  
**Issue:** The function returns `table.unpack(return_values)` but `return_values` might be a single-element table `{nil}` when no return value is set. This is correct but could be optimized.  
**Impact:** None - works correctly but slightly inefficient.  
**Fix:** Minor optimization (optional):
```lua
if #return_values == 1 then
  return return_values[1]
else
  return table.unpack(return_values)
end
```

### 9. Missing Validation in `toHaveBeenNthCalledWith`
**File:** `test_api.lua:321-346`  
**Issue:** The function doesn't validate that `n` is a positive integer.  
**Impact:** Confusing error messages if called with invalid index.  
**Fix:** Add validation:
```lua
custom_matchers.toHaveBeenNthCalledWith = function(n, ...)
  if type(n) ~= 'number' or n < 1 or math.floor(n) ~= n then
    error('toHaveBeenNthCalledWith() expects a positive integer as first argument, got ' .. tostring(n), 3)
  end
  -- ... rest of function
end
```

## Recommendations Summary

**Priority 1 (Must Fix):**
1. Fix unused parameter in `expect_that` (expects.lua:31)
2. Fix `table.concat` on non-string values (test_api.lua:289, 307, 313, 316, 334, 340, 343)
3. Fix naming inconsistency `satisfyAny` vs `satisfy_any` (test_api.lua:135)

**Priority 2 (Should Fix):**
4. Add type validation to `contains` matcher (matchers.lua:285)
5. Improve error message formatting for matchers (test_api.lua:266-346)
6. Add nil handling documentation/comments (test_api.lua:207-231)

**Priority 3 (Nice to Have):**
7. Improve error message formatting (expects.lua:36)
8. Add validation to `toHaveBeenNthCalledWith` (test_api.lua:321)
9. Minor optimization in mock return values (mock.lua:173)

