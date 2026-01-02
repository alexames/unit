# TODO: Missing Jest Features

This document tracks Jest features that are not yet implemented in this unit testing library.

## Test Control & Filtering

### test.only() / it.only() / describe.only()
Run only specific tests, skipping all others. Useful for debugging individual tests.
- `it.only('test name', function() ... end)` - Run only this test
- `describe.only('suite name', function() ... end)` - Run only this suite

### test.skip() / it.skip() / describe.skip()
Skip specific tests without removing them from the codebase.
- `it.skip('test name', function() ... end)` - Skip this test
- `describe.skip('suite name', function() ... end)` - Skip this entire suite

### test.todo()
Mark tests as TODO items that should be implemented later.
- `it.todo('test name')` - Creates a placeholder test that will fail until implemented

### Test Name Filtering
Filter tests by name pattern (regex or string matching) when running tests.
- `run_tests("pattern")` - Currently only filters by suite name, should support test name patterns

## Lifecycle Hooks

### beforeAll() / afterAll()
Run setup/teardown code once per test suite, before/after all tests in the suite.
- `beforeAll(function() ... end)` - Runs once before all tests in the suite
- `afterAll(function() ... end)` - Runs once after all tests in the suite
- Currently only `beforeEach`/`afterEach` exist (run before/after each test)

### Global Lifecycle Hooks
Setup/teardown that runs once for the entire test run, not per suite.
- Global `beforeAll`/`afterAll` hooks
- `setupFiles` - Files to run before test execution
- `setupFilesAfterEnv` - Files to run after test environment setup

## Async Testing

### Async/Await Support
Support for async test functions and automatic promise handling.
- `it('test', async function() ... end)` - Async test functions
- Automatic waiting for promises to resolve/reject

### Promise Matchers
Matchers for testing promises directly.
- `expect(promise).resolves.toBe(value)` - Test resolved promise value
- `expect(promise).rejects.toThrow()` - Test rejected promise error

### Done Callback
Callback-based async test support for older async patterns.
- `it('test', function(done) ... done() end)` - Call done() when async work completes

## Advanced Matchers

### expect.any(constructor)
Match any instance of a given type/class.
- `expect(value).toBe(expect.any('string'))` - Match any string
- `expect(value).toBe(expect.any('table'))` - Match any table

### expect.anything()
Match anything except null/undefined.
- `expect(value).toBe(expect.anything())` - Match any non-nil value

### expect.arrayContaining(array)
Match an array that contains all elements from the expected array (subset matching).
- `expect([1, 2, 3]).toEqual(expect.arrayContaining([2, 3]))` - Array contains subset

### expect.objectContaining(object)
Match an object that contains all properties from the expected object (subset matching).
- `expect({a: 1, b: 2, c: 3}).toEqual(expect.objectContaining({a: 1, b: 2}))` - Object contains subset

### expect.stringContaining(string)
Match a string containing the given substring (different API from current `Contains`).
- `expect('hello world').toMatch(expect.stringContaining('world'))` - String contains substring

### expect.stringMatching(regexp)
Match a string matching the given regex pattern (different API from current `Matches`).
- `expect('hello123').toMatch(expect.stringMatching('%d+'))` - String matches pattern

### Negated Array/Object Matchers
Negated versions of array and object subset matchers.
- `expect(array).not.toEqual(expect.arrayContaining([...]))`
- `expect(object).not.toEqual(expect.objectContaining({...}))`

### expect.closeTo(number, numDigits)
Floating point comparison with specified precision (different API from current `Near`).
- `expect(0.1 + 0.2).toBeCloseTo(0.3, 5)` - Compare with 5 decimal places

### expect.toBeInstanceOf(Class)
Check if value is an instance of a class (different API from current `IsOfType`).
- `expect(value).toBeInstanceOf(MyClass)` - Instance check

## Snapshot Testing

### toMatchSnapshot()
Capture and compare snapshots of values over time for regression testing.
- `expect(value).toMatchSnapshot()` - Create/compare snapshot
- Snapshot files stored in `__snapshots__` directory

### toMatchInlineSnapshot()
Inline snapshots stored directly in test file.
- `expect(value).toMatchInlineSnapshot('expected value')` - Inline snapshot

### Snapshot Management
Tools for managing snapshot files.
- Update snapshots command
- Review snapshot changes
- Prune obsolete snapshots

## Mocking & Module System

### jest.mock(moduleName)
Automatically mock modules when imported.
- `jest.mock('./module')` - Auto-mock module
- Module factory: `jest.mock('./module', function() return {...} end)`

### jest.unmock(moduleName)
Prevent automatic mocking of a module.
- `jest.unmock('./module')` - Don't mock this module

### jest.doMock() / jest.dontMock()
Dynamically mock/unmock modules at runtime.
- `jest.doMock('./module')` - Dynamic mock
- `jest.dontMock('./module')` - Dynamic unmock

### jest.requireActual()
Require the actual (non-mocked) version of a module.
- `local actual = jest.requireActual('./module')` - Get real module

### jest.requireMock()
Require the mocked version of a module.
- `local mocked = jest.requireMock('./module')` - Get mocked module

### Manual Mocks
Support for `__mocks__` directory with manual mock implementations.
- Place mocks in `__mocks__/module.lua`
- Automatically used when module is mocked

### jest.clearAllMocks()
Clear call history for all mocks globally.
- `jest.clearAllMocks()` - Clear all mock call histories

### jest.resetAllMocks()
Reset all mocks to initial state globally.
- `jest.resetAllMocks()` - Reset all mocks (clear + reset return values)

### jest.restoreAllMocks()
Restore all spies to original implementations globally.
- `jest.restoreAllMocks()` - Restore all spy implementations

### jest.isolateModules()
Isolate module cache between tests.
- `jest.isolateModules(function() ... end)` - Isolated module scope

## Timer Mocks

### jest.useFakeTimers()
Replace real timers with fake, controllable timers.
- `jest.useFakeTimers()` - Enable fake timers
- Control time advancement manually

### jest.useRealTimers()
Restore real timers.
- `jest.useRealTimers()` - Use real system timers

### jest.advanceTimersByTime(ms)
Advance fake timers by specified milliseconds.
- `jest.advanceTimersByTime(1000)` - Advance by 1 second

### jest.runOnlyPendingTimers()
Run only currently pending timers.
- `jest.runOnlyPendingTimers()` - Run pending timers

### jest.runAllTimers()
Run all timers until none remain.
- `jest.runAllTimers()` - Run all timers

### jest.clearAllTimers()
Clear all pending timers.
- `jest.clearAllTimers()` - Clear timer queue

### jest.setSystemTime()
Set the system time when using fake timers.
- `jest.setSystemTime(1000000)` - Set system time

## Test Utilities

### jest.fn() API Improvements
More concise API for creating mocks (alternative to current `Mock()`).
- `local mock = jest.fn()` - Create mock
- `mock = jest.fn(function() return 42 end)` - Mock with implementation

### jest.spyOn() API Improvements
Enhanced spy API with property descriptor support.
- `local spy = jest.spyOn(obj, 'method')` - Spy on method
- Support for getters/setters
- Automatic restore option

### jest.replaceProperty()
Replace object properties with mocks.
- `jest.replaceProperty(obj, 'prop', mockValue)` - Replace property

## Configuration & Execution

### Watch Mode
Automatically re-run tests when files change.
- `jest --watch` - Watch mode
- Interactive menu for filtering tests
- Only run tests related to changed files

### Parallel Execution
Run tests in parallel for better performance.
- Automatic parallelization
- Worker processes/threads
- Test isolation in parallel mode

### Test Timeout Configuration
Configure timeouts for tests.
- Per-test timeout: `it('test', function() ... end, 5000)` - 5 second timeout
- Global timeout configuration
- Suite-level timeout

### Coverage Collection
Built-in code coverage reporting.
- `jest --coverage` - Generate coverage report
- Line coverage, branch coverage, function coverage
- Coverage thresholds
- HTML/JSON coverage reports

### Test Environment Configuration
Configure test execution environment.
- `jsdom` environment (for DOM testing)
- `node` environment
- Custom environments
- Environment-specific setup

### Setup Files
Files to run before test execution.
- `setupFiles` - Run before test framework setup
- `setupFilesAfterEnv` - Run after test environment setup

### Global Setup/Teardown
Global setup/teardown functions.
- `globalSetup` - Run once before all tests
- `globalTeardown` - Run once after all tests

### Test Reporters
Custom test result reporters.
- Custom reporter API
- Multiple reporters
- Reporter configuration

### Test Result Processors
Transform test results before reporting.
- Result transformation pipeline
- Custom result formats

## Advanced Features

### Custom Matcher Extensions
API for extending expect with custom matchers.
- `expect.extend({ toBeCustom: function(actual, expected) ... end })` - Add custom matcher
- Custom matcher API with proper error messages

### Custom Equality Testers
Custom equality comparison logic.
- `addEqualityMatcher(function(a, b) ... end)` - Custom equality

### Test Isolation
Ensure tests run in complete isolation.
- Isolated global state
- Isolated module cache
- Isolated environment variables

### Module Resolution
Jest's module resolution system.
- Module path resolution
- Module name mapping
- Path aliases

### Transform Support
Code transformation pipeline.
- Babel/TypeScript transforms
- Custom transformers
- Transform configuration

### Haste Map
Fast file system cache for module resolution.
- File system indexing
- Fast module lookups
- Cache invalidation

### Test Retries
Retry failed tests automatically.
- `jest.retryTimes(3)` - Retry failed tests 3 times
- Retry configuration

### Bail Mode
Stop test execution on first failure.
- `jest --bail` - Stop on first failure
- Bail configuration

### Verbose Mode
Detailed test output options.
- `jest --verbose` - Verbose output
- Different verbosity levels

### Silent Mode
Suppress console output during tests.
- `jest --silent` - Suppress console
- Selective console suppression

### Test Name Patterns
Regex matching for test names.
- `jest -t "pattern"` - Run tests matching pattern
- Pattern matching configuration

## API Improvements

### Matcher Naming Consistency
Align matcher names with Jest conventions.
- `toBe()` instead of `beEqualTo()` (or support both)
- `toEqual()` as alias for `toBe()` (or separate for deep equality)
- `toThrow()` instead of `throw()` (or support both)

### Mock Return Value Chaining
Support method chaining for mock configuration.
- `mock:mockReturnValue(1):mockReturnValueOnce(2):mockReturnValueOnce(3)` - Chain methods

### expect().toThrow() API
Improve error throwing matcher API.
- `expect(fn).toThrow()` - Should throw
- `expect(fn).toThrow('error message')` - Should throw with message
- `expect(fn).toThrow(/pattern/)` - Should throw matching pattern

## Notes

- Some features may not be applicable to Lua (e.g., DOM testing, Babel transforms)
- Priority should be given to features that enhance developer experience and test reliability
- Consider Lua-specific adaptations where JavaScript concepts don't directly translate

