--[[
mathdown-reader.lua — CommonMark with LaTeX-style paragraphs.

In Markdown, the text after a display, list or quote always starts a new
paragraph. Here, as in LaTeX, a blank line decides:

    … so that               … so that
    ```                     ```
    a = b                   a = b
    ```                     ```
    which proves it.
                            Which proves it.
    (same paragraph)        (new paragraph)

The reader rewrites the source before CommonMark sees it: text that follows a
closing fence, list or quote without a blank line gets a "_ " marker (which
mathdown.lua turns into a paragraph continuation), plus the blank line that
Markdown needs to end a list or quote. A "*Proof.*" or bold keyword line right
after a list or quote only gets the blank line.

Use with  from: mathdown-reader.lua  and  data-dir: ${.}  in the defaults
file, with this file in custom/ next to it.
To see the rewritten source:  MATHDOWN_DUMP=1 pandoc … (printed to stderr)
]]

local M = {}

local function blank(l) return l:match('^%s*$') ~= nil end
local function indented(l) return l:match('^%s') ~= nil end
local function list_marker(l)
  return l:match('^%s*[-+*]%s') or l:match('^%s*%d+[.)]%s')
end
local function quote(l) return l:match('^%s*>') ~= nil end
local function fence(l)
  local f = l:match('^%s*(```+)') or l:match('^%s*(~~~+)')
  return f
end

-- Lines that start a block of their own: never a continuation.
local function starts_block(l)
  return list_marker(l) or quote(l) or fence(l)
    or l:match('^%s*#') or l:match('^%s*|')
    or l:match('^%s*%*Proof[.:]?%*') or l:match('^%s*_Proof[.:]?_')
    or l:match('^%s*%*%*%a') or l:match('^%s*%-%-%-+%s*$')
    or l:match('^%s*\\') or l:match('^%s*<')
end

function M.preprocess(text)
  local lines = {}
  for l in (text .. '\n'):gmatch('(.-)\r?\n') do lines[#lines + 1] = l end
  if lines[#lines] == '' then lines[#lines] = nil end

  local out = {}
  local i = 1

  -- YAML front matter passes through untouched
  if lines[1] == '---' then
    out[1] = lines[1]
    i = 2
    while i <= #lines do
      out[#out + 1] = lines[i]
      i = i + 1
      if lines[i - 1] == '---' or lines[i - 1] == '...' then break end
    end
  end

  local after = nil      -- 'fence', 'list' or 'quote': what the previous line ended
  local in_list, in_quote = false, false

  while i <= #lines do
    local l = lines[i]

    if fence(l) then
      -- copy the whole fenced block; it ends a block on its closing line
      local f = fence(l)
      out[#out + 1] = l
      i = i + 1
      while i <= #lines do
        out[#out + 1] = lines[i]
        local close = lines[i]:match('^%s*([`~]+)%s*$')
        i = i + 1
        if close and close:sub(1, 1) == f:sub(1, 1) and #close >= #f then break end
      end
      after, in_list, in_quote = 'fence', false, false

    elseif blank(l) then
      out[#out + 1] = l
      after = nil
      -- a list or quote survives a blank line only if indented text follows
      if in_list and lines[i + 1] and not indented(lines[i + 1])
          and not list_marker(lines[i + 1]) then
        in_list = false
      end
      in_quote = false
      i = i + 1

    elseif list_marker(l) then
      out[#out + 1] = l
      in_list, in_quote = true, false
      after = 'list'
      i = i + 1

    elseif quote(l) then
      out[#out + 1] = l
      in_quote, in_list = true, false
      after = 'quote'
      i = i + 1

    elseif in_list and indented(l) then
      out[#out + 1] = l          -- wrapped text of a list item
      after = 'list'
      i = i + 1

    elseif after then
      -- text directly after a fence, list or quote
      if after ~= 'fence' then out[#out + 1] = '' end   -- end the list/quote
      if starts_block(l) or l:match('^%s*_%s') then
        out[#out + 1] = l
      else
        out[#out + 1] = '_ ' .. l:gsub('^%s+', '')
      end
      after, in_list, in_quote = nil, false, false
      i = i + 1

    else
      out[#out + 1] = l
      in_list, in_quote = false, false
      i = i + 1
    end
  end
  return table.concat(out, '\n') .. '\n'
end

function Reader(input, opts)
  local text = M.preprocess(tostring(input))
  -- MATHDOWN_DUMP=1 pandoc … prints the rewritten source to stderr
  local dump = os.getenv('MATHDOWN_DUMP')
  if dump and dump ~= '' then io.stderr:write(text) end
  return pandoc.read(text, 'commonmark_x', opts)
end
