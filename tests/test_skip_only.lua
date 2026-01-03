-- Tests for skip/only functionality

local unit = require 'unit.test_api'

local describe = unit.describe
local it = unit.it
local expect = unit.expect

describe('Skip and Only Functionality', function()

  describe('it.skip', function()
    it('should allow skipping individual tests', function()
      -- This test verifies that skip functionality exists
      expect(type(it.skip)).to.be_equal_to('function')
    end)

    -- This test should be skipped
    it.skip('this test should be skipped', function()
      -- This should never run
      expect(true).to.be_false()
    end)
  end)

  describe('it.only', function()
    it('should allow running only specific tests', function()
      -- This test verifies that only functionality exists
      expect(type(it.only)).to.be_equal_to('function')
    end)
  end)

  describe('describe.skip', function()
    it('should allow skipping test suites', function()
      expect(type(describe.skip)).to.be_equal_to('function')
    end)
  end)

  describe('describe.only', function()
    it('should allow running only specific test suites', function()
      expect(type(describe.only)).to.be_equal_to('function')
    end)
  end)
end)

-- This entire suite should be skipped
describe.skip('Skipped Test Suite', function()
  it('should never run', function()
    expect(true).to.be_false()
  end)

  it('should also never run', function()
    error('This should not execute')
  end)
end)
