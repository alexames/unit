local llx = require 'llx'

local isinstance = llx.isinstance

local function table_to_string(t)
  local s = '{'
  local first = true
  for k, v in pairs(t) do
    if first then
      s = s .. tostring(k) .. ' = ' .. tostring(v)
      first = false
    else
      s = s .. ', ' .. tostring(k) .. ' = ' .. tostring(v)
    end
  end
  return s .. '}'
end

function Not(predicate)
  return function(actual)
    local result, act, msg, nmsg, exp = predicate(actual)
    return not result, act, nmsg, msg, exp
  end
end

function Equals(expected)
  return function(actual)
    return
      actual == expected,
      tostring(actual),
      'be equal to',
      'be not equal to',
      tostring(expected)
  end
end

function GreaterThan(expected)
  return function(actual)
    return
      actual > expected,
      tostring(actual),
      'be greater than',
      'be not greater than',
      tostring(expected)
  end
end

function GreaterThanOrEqual(expected)
  return function(actual)
    return
      actual >= expected,
      tostring(actual),
      'be greater than or equal to',
      'be not greater than or equal to',
      tostring(expected)
  end
end

function LessThan(expected)
  return function(actual)
    return
      actual < expected,
      tostring(actual),
      'be less than',
      'be not less than',
      tostring(expected)
  end
end

function LessThanOrEqual(expected)
  return function(actual)
    return
      actual <= expected,
      tostring(actual),
      'be less than or equal to',
      'be not less than or equal to',
      tostring(expected)
  end
end

function StartsWith(expected)
  return function(actual)
    return
      actual:startswith(expected),
      tostring(actual),
      'start with',
      'not start with',
      tostring(expected)
  end
end

function EndsWith(expected)
  return function(actual)
    return
      actual:endswith(expected),
      tostring(actual),
      'end with',
      'not end with',
      tostring(expected)
  end
end

function IsOfType(expected)
  return function(actual)
    return
      isinstance(actual, expected),
      tostring(actual),
      'be of type',
      'not be of type',
      tostring(expected)
  end
end

function Listwise(predicate_generator, expected)
  return function(actual)
    local result = true
    local act, msg, nmsg, exp
    local act_list, exp_list = {}, {}
    local largest_len = #actual > #expected and #actual or #expected
    for i=1, largest_len do
      local predicate = predicate_generator(expected[i])
      local local_result
      local_result, act, msg, nmsg, exp = predicate(actual[i])
      act_list[i], exp_list[i] = act, exp
      result = result and local_result
    end
    return result,
           '{' .. (','):join(act_list) .. '}',
           msg .. ' the value at every index of',
           'not to ' .. msg .. ' the value at every index of',
           '{' .. (','):join(exp_list) .. '}'
  end
end

local function collect_keys(out, ...)
  for i, t in ipairs{...} do
    for k, v in pairs(t) do
      out[k] = true
    end
  end
  return out
end

function Tablewise(predicate_generator, expected)
  return function(actual)
    local result = true
    local act, msg, nmsg, exp
    local act_list, exp_list = {}, {}
    local keys = collect_keys({}, actual, expected)
    for k, _ in pairs(keys) do
      local predicate = predicate_generator(expected[k])
      local local_result
      local_result, act, msg, nmsg, exp = predicate(actual[k])
      result = result and local_result
    end
    return result,
           table_to_string(actual),
           msg .. ' the value at every key of',
           'not to ' .. msg .. ' the value at every key of',
           table_to_string(expected)
  end
end

return {
  Not=Not,
  Equals=Equals,
  GreaterThan=GreaterThan,
  GreaterThanOrEqual=GreaterThanOrEqual,
  LessThan=LessThan,
  LessThanOrEqual=LessThanOrEqual,
  StartsWith=StartsWith,
  EndsWith=EndsWith,
  IsOfType=IsOfType,
  Listwise=Listwise,
  Tablewise=Tablewise,
}
