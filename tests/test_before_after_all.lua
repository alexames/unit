local unit = require 'unit'

_ENV = unit.create_test_env(_ENV)

-- Track execution order for verification
local execution_log = {}

describe('BeforeAllAfterAllTests', function()
  before_all(function()
    table.insert(execution_log, 'suite_beforeAll')
  end)
  
  after_all(function()
    table.insert(execution_log, 'suite_afterAll')
  end)
  
  before_each(function()
    table.insert(execution_log, 'beforeEach')
  end)
  
  after_each(function()
    table.insert(execution_log, 'afterEach')
  end)
  
  it('should run beforeAll once before all tests', function()
    table.insert(execution_log, 'test1')
    expect(execution_log[1]).to.beEqualTo('suite_beforeAll')
  end)
  
  it('should run beforeAll only once for multiple tests', function()
    table.insert(execution_log, 'test2')
    -- beforeAll should only appear once
    local before_all_count = 0
    for _, item in ipairs(execution_log) do
      if item == 'suite_beforeAll' then
        before_all_count = before_all_count + 1
      end
    end
    expect(before_all_count).to.beEqualTo(1)
  end)
  
  it('should run afterAll after all tests complete', function()
    table.insert(execution_log, 'test3')
    -- afterAll should not have run yet (it runs after all tests)
    local has_after_all = false
    for _, item in ipairs(execution_log) do
      if item == 'suite_afterAll' then
        has_after_all = true
        break
      end
    end
    expect(has_after_all).to.beEqualTo(false)
  end)
end)

describe('NestedBeforeAllAfterAllTests', function()
  before_all(function()
    table.insert(execution_log, 'parent_beforeAll')
  end)
  
  after_all(function()
    table.insert(execution_log, 'parent_afterAll')
  end)
  
  it('should run parent beforeAll', function()
    table.insert(execution_log, 'parent_test')
  end)
  
  describe('NestedSuite', function()
    before_all(function()
      table.insert(execution_log, 'nested_beforeAll')
    end)
    
    after_all(function()
      table.insert(execution_log, 'nested_afterAll')
    end)
    
    it('should run both parent and nested beforeAll', function()
      table.insert(execution_log, 'nested_test')
      -- Check that both beforeAll hooks ran
      local has_parent = false
      local has_nested = false
      for _, item in ipairs(execution_log) do
        if item == 'parent_beforeAll' then
          has_parent = true
        elseif item == 'nested_beforeAll' then
          has_nested = true
        end
      end
      expect(has_parent).to.beTruthy()
      expect(has_nested).to.beTruthy()
    end)
  end)
end)

describe('GlobalBeforeAllAfterAllTests', function()
  it('should verify global hooks run', function()
    -- This test verifies global hooks are called
    -- The actual verification happens in the global hooks themselves
    expect(true).to.beTruthy()
  end)
end)

-- Set up global hooks
global_before_all(function()
  table.insert(execution_log, 'global_beforeAll')
end)

global_after_all(function()
  table.insert(execution_log, 'global_afterAll')
  -- Verify execution order: global_beforeAll should be first
  expect(execution_log[1]).to.beEqualTo('global_beforeAll')
end)

run_unit_tests()

