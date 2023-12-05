require 'llx'

local test_index = 0
function test(name)
  test_index = test_index + 1
  local mt = {
    __sub = function(self, str) 
      table.insert(self.name, str)
      return self
    end,

    __bor = function(self, t)
       table.insert(self.parameters, t)
       return self
    end,
  }
  local t = {index = test_index, name={name}, parameter={}, __istest=true}
  return setmetatable(t, mt)
end

local function is_test(t)
  return isinstance(t, Table) and t.__istest
end

local Test = class 'Test' {
  setup = noop;
  teardown = noop;

  __init = function(self)
    self._tests = self:gather_tests()
    self._name = getmetatable(self).__name or '<name>'
  end,

  tests = function(self) return self._tests end;
  name = function(self) return self._name end;

  gather_tests = function(self)
    -- Convert this to a List
    local result = Table()
    for key, testfunc in pairs(getmetatable(self)) do
      if is_test(key) then
        result:insert({index=key.index, name=key.name, func=testfunc})
      end
    end
    result:sort(function(a, b) return a.index < b.index end)
    return result
  end,

  run_test = function(self, printer, test, ...)
    printer.test_begin(self, test.name)
    local successful, err
    self:setup()
    local successful, err = pcall(test.func, ...)
    self:teardown()
    printer.test_end(self, test.name, successful, err)
    return successful, err
  end,

  run_tests = function(self, printer)
    printer.class_preamble(self)
    local failure_count = 0
    for i, test in pairs(self._tests) do
      if test.arguments == nil or #test.arguments == 0 then
        local successful = self:run_test(printer, test)
        if not successful then
          failure_count = failure_count + 1
        end
      else
        for i, arguments in product(table.unpack(test.arguments)) do
          local successful = self:run_test(test, table.unpack(arguments))
          if not successful then
            failure_count = failure_count + 1
          end
        end
      end
    end
    printer.class_conclusion(self, failure_count)
    return failure_count, #self._tests
  end,
}

return {
  Test=Test,
}
