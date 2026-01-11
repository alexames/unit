-- LDoc configuration for unit
-- Run with: ldoc .

project = 'unit'
title = 'unit - Lua Unit Testing Framework'
description = [[
A lightweight unit testing framework for Lua with a modern describe/it API.
Provides expressive assertions with custom matchers, flexible mocking with
call expectations and argument validation, and colored terminal output.
]]

-- Source files
file = {
  '.',
  exclude = {
    'tests',
  }
}

-- Output directory
dir = 'docs'

-- Use markdown for descriptions
format = 'markdown'

-- Sort alphabetically
sort = true

-- Include all documented items
all = true

-- Template style (use default LDoc style)
-- style = nil uses the built-in ldoc.css
template = nil

-- Package display name
package = 'unit'

-- One file per module
one = false

-- Show source code links
no_return_or_parms = false
no_summary = false

-- Merge modules into single pages
merge = false

-- Manual pages
readme = 'README.md'

-- Custom tags
custom_tags = {
  {'example', title = 'Example', format = nil},
  {'usage', title = 'Usage', format = nil},
}
