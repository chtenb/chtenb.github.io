--[[
mathdown.lua — turn Markdown with Unicode math in backticks into a math paper.

  `a ⊆ b`               inline code      → inline math
  ```                    unlabelled fence → displayed math
  a + b = c       (1)      - equation chains are aligned on their relation,
      = d         (2)      - a trailing "(...)" after 2+ spaces is a justification,
  ```                      - columns separated by 3+ spaces become align columns,
                           - lines with "  if " become a cases block.
  **Theorem (Name)**     → theorem environment; the bold keyword line is its
  For all …                head, like a heading. The body is the rest of that
                           paragraph, or the next block if a blank line follows.
                           (Also Definition, Example, Lemma, Corollary, Remark, …)
  _ text after a display → continues the paragraph (otherwise a new one starts)
  *Proof.* … ∎           → proof environment, up to the block holding ∎.
                           A proof or keyword may also start on a new line
                           inside a paragraph (no blank line needed).
  Headings are left to pandoc.

Opt out with a class: `x := 1`{.code} or ```lua … ``` stays code.
Raw TeX inside backticks passes through: `\alpha + \beta`.
]]

local stringify = pandoc.utils.stringify

-- Bold keywords that open a theorem-like environment. In LaTeX they become
-- md<keyword> (mdtheorem, mddefinition, …), so they never clash with a
-- document class that defines its own theorem or example commands.
local ENVS = { theorem=1, lemma=1, proposition=1, corollary=1, definition=1,
  example=1, remark=1, conjecture=1, claim=1, axiom=1, notation=1 }

---------------------------------------------------------------------------
-- Unicode → TeX
---------------------------------------------------------------------------

local SYM = {
  ['⋅']='\\cdot ', ['·']='\\cdot ', ['∈']='\\in ', ['∉']='\\notin ', ['∋']='\\ni ',
  ['∪']='\\cup ', ['∩']='\\cap ', ['∅']='\\emptyset ', ['⊆']='\\subseteq ',
  ['⊇']='\\supseteq ', ['⊂']='\\subset ', ['⊃']='\\supset ', ['⊊']='\\subsetneq ',
  ['≤']='\\le ', ['≥']='\\ge ', ['≠']='\\neq ', ['≅']='\\cong ', ['≡']='\\equiv ',
  ['≈']='\\approx ', ['∼']='\\sim ', ['≺']='\\prec ', ['≼']='\\preceq ',
  ['∞']='\\infty ', ['∖']='\\setminus ', ['⋃']='\\bigcup', ['⋂']='\\bigcap',
  ['⨆']='\\bigsqcup', ['∑']='\\sum', ['∏']='\\prod', ['∐']='\\coprod',
  ['⊓']='\\sqcap ', ['⊔']='\\sqcup ', ['⊥']='\\bot ', ['⊤']='\\top ',
  ['∨']='\\vee ', ['∧']='\\wedge ', ['⋁']='\\bigvee', ['⋀']='\\bigwedge',
  ['¬']='\\neg ', ['∀']='\\forall ', ['∃']='\\exists ', ['∄']='\\nexists ',
  ['→']='\\to ', ['←']='\\leftarrow ', ['↦']='\\mapsto ', ['↔']='\\leftrightarrow ',
  ['⇒']='\\Rightarrow ', ['⇐']='\\Leftarrow ', ['⇔']='\\Leftrightarrow ',
  ['⟹']='\\Longrightarrow ', ['⟸']='\\Longleftarrow ', ['⟺']='\\Longleftrightarrow ',
  ['↪']='\\hookrightarrow ', ['↠']='\\twoheadrightarrow ',
  ['×']='\\times ', ['∘']='\\circ ', ['⊕']='\\oplus ', ['⊗']='\\otimes ',
  ['⊢']='\\vdash ', ['⊨']='\\models ', ['∣']='\\mid ', ['∥']='\\parallel ',
  ['⟨']='\\langle ', ['⟩']='\\rangle ', ['⌊']='\\lfloor ', ['⌋']='\\rfloor ',
  ['⌈']='\\lceil ', ['⌉']='\\rceil ', ['…']='\\dots ', ['⋯']='\\cdots ',
  ['−']='-', ['∂']='\\partial ', ['∇']='\\nabla ', ['∫']='\\int', ['√']='\\sqrt',
  ['ℕ']='\\mathbb{N}', ['ℤ']='\\mathbb{Z}', ['ℚ']='\\mathbb{Q}', ['ℝ']='\\mathbb{R}',
  ['ℂ']='\\mathbb{C}', ['𝔹']='\\mathbb{B}', ['∎']='',
  ['α']='\\alpha ', ['β']='\\beta ', ['γ']='\\gamma ', ['δ']='\\delta ',
  ['ε']='\\varepsilon ', ['ζ']='\\zeta ', ['η']='\\eta ', ['θ']='\\theta ',
  ['ι']='\\iota ', ['κ']='\\kappa ', ['λ']='\\lambda ', ['μ']='\\mu ',
  ['ν']='\\nu ', ['ξ']='\\xi ', ['π']='\\pi ', ['ρ']='\\rho ', ['σ']='\\sigma ',
  ['τ']='\\tau ', ['υ']='\\upsilon ', ['φ']='\\varphi ', ['χ']='\\chi ',
  ['ψ']='\\psi ', ['ω']='\\omega ', ['Γ']='\\Gamma ', ['Δ']='\\Delta ',
  ['Θ']='\\Theta ', ['Λ']='\\Lambda ', ['Ξ']='\\Xi ', ['Π']='\\Pi ',
  ['Σ']='\\Sigma ', ['Φ']='\\Phi ', ['Ψ']='\\Psi ', ['Ω']='\\Omega ',
  ['±']='\\pm ', ['∓']='\\mp ', ['÷']='\\div ', ['∙']='\\bullet ', ['⋆']='\\star ',
  ['⊖']='\\ominus ', ['⊙']='\\odot ', ['⊎']='\\uplus ', ['⋄']='\\diamond ',
  ['≪']='\\ll ', ['≫']='\\gg ', ['≻']='\\succ ', ['≽']='\\succeq ',
  ['⊏']='\\sqsubset ', ['⊐']='\\sqsupset ', ['⊑']='\\sqsubseteq ', ['⊒']='\\sqsupseteq ',
  ['⊈']='\\nsubseteq ', ['⊉']='\\nsupseteq ', ['⊄']='\\not\\subset ',
  ['≃']='\\simeq ', ['≲']='\\lesssim ', ['≳']='\\gtrsim ', ['∝']='\\propto ',
  ['≔']='\\coloneqq ', ['≜']='\\triangleq ', ['∤']='\\nmid ', ['⊩']='\\Vdash ',
  ['⊲']='\\lhd ', ['⊳']='\\rhd ', ['⊸']='\\multimap ',
  ['⟶']='\\longrightarrow ', ['⟵']='\\longleftarrow ', ['⟼']='\\longmapsto ',
  ['↑']='\\uparrow ', ['↓']='\\downarrow ', ['⇑']='\\Uparrow ', ['⇓']='\\Downarrow ',
  ['⋮']='\\vdots ', ['⋱']='\\ddots ', ['∴']='\\therefore ', ['∵']='\\because ',
  ['ℓ']='\\ell ', ['℘']='\\wp ', ['°']='^{\\circ}', ['□']='\\square ',
  ['◇']='\\Diamond ', ['△']='\\triangle ', ['∮']='\\oint', ['∬']='\\iint',
}
-- Mathematical script / blackboard capitals (𝒜…𝒵, 𝔸…𝕐)
do
  local script = { [0x1D49C]='A', [0x212C]='B', [0x1D49E]='C', [0x1D49F]='D',
    [0x2130]='E', [0x2131]='F', [0x1D4A2]='G', [0x210B]='H', [0x2110]='I',
    [0x1D4A5]='J', [0x1D4A6]='K', [0x2112]='L', [0x2133]='M', [0x1D4A9]='N',
    [0x1D4AA]='O', [0x1D4AB]='P', [0x1D4AC]='Q', [0x211B]='R', [0x1D4AE]='S',
    [0x1D4AF]='T', [0x1D4B0]='U', [0x1D4B1]='V', [0x1D4B2]='W', [0x1D4B3]='X',
    [0x1D4B4]='Y', [0x1D4B5]='Z' }
  for cp, l in pairs(script) do SYM[utf8.char(cp)] = '\\mathcal{' .. l .. '}' end
  for k = 0, 25 do
    local c = utf8.char(0x1D538 + k)
    if not SYM[c] then SYM[c] = '\\mathbb{' .. string.char(65 + k) .. '}' end
  end
end

local SUB = { ['₀']='0', ['₁']='1', ['₂']='2', ['₃']='3', ['₄']='4', ['₅']='5',
  ['₆']='6', ['₇']='7', ['₈']='8', ['₉']='9', ['₊']='+', ['₋']='-', ['₌']='=',
  ['ₐ']='a', ['ₑ']='e', ['ₒ']='o', ['ₓ']='x', ['ₕ']='h', ['ₖ']='k', ['ₗ']='l',
  ['ₘ']='m', ['ₙ']='n', ['ₚ']='p', ['ₛ']='s', ['ₜ']='t', ['ᵢ']='i', ['ⱼ']='j',
  ['ᵣ']='r', ['ᵤ']='u', ['ᵥ']='v' }
local SUP = { ['⁰']='0', ['¹']='1', ['²']='2', ['³']='3', ['⁴']='4', ['⁵']='5',
  ['⁶']='6', ['⁷']='7', ['⁸']='8', ['⁹']='9', ['⁺']='+', ['⁻']='-', ['⁼']='=',
  ['ⁿ']='n', ['ⁱ']='i', ['ᵏ']='k', ['ᵐ']='m', ['ˣ']='x', ['ʸ']='y', ['ᵀ']='T',
  ['′']="'", ['″']="''", ['∗']='*' }

-- Named operators set upright with proper spacing.
local OPS = { max=1, min=1, sup=1, inf=1, lim=1, log=1, ln=1, exp=1, sin=1,
  cos=1, tan=1, ker=1, dim=1, deg=1, gcd=1, det=1, arg=1, Pr=1 }
-- Connective words set as text inside math.
local WORDS = { ['if']=1, ['iff']=1, ['and']=1, ['or']=1, ['otherwise']=1,
  ['for']=1, ['where']=1, ['when']=1, ['else']=1, ['then']=1, ['by']=1 }

local function chars(s)
  local t = {}
  for _, cp in utf8.codes(s) do t[#t + 1] = utf8.char(cp) end
  return t
end

local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Translate one Unicode math expression to TeX.
-- text_words: set multi-letter words with \text (for justifications).
local tex
tex = function(s, text_words)
  local c = chars(s)
  local out, n, i = {}, #c, 1
  local prev_atom = false          -- last emitted thing can carry a superscript
  local function emit(x, atom) out[#out + 1] = x; prev_atom = atom end
  while i <= n do
    local ch = c[i]
    if ch == '\\' and i < n and c[i + 1]:match('^%a$') then
      -- raw TeX command: copy it verbatim
      local j = i + 1
      while j <= n and c[j]:match('^%a$') do j = j + 1 end
      emit(table.concat(c, '', i, j - 1) .. ' ', true); i = j
    elseif ch == '\\' and i < n then
      emit('\\' .. c[i + 1], true); i = i + 2
    elseif ch:match('^%a$') then
      local j = i
      while j <= n and (c[j]:match('^%a$')
          -- in justifications "Named-Sum" is one hyphenated word, not a minus
          or (text_words and c[j] == '-' and c[j + 1] and c[j + 1]:match('^%a$'))) do
        j = j + 1
      end
      local w = table.concat(c, '', i, j - 1)
      -- keep a word space between an identifier and a following word
      local gap = (prev_atom and c[i - 1] == ' ') and '\\ ' or ''
      if #w == 1 then emit(w, true)
      elseif OPS[w] then emit('\\' .. w .. ' ', true)
      elseif WORDS[w] then
        -- "x = 1  and  y = 2": two spaces in the source give a wide gap
        local wide = c[i - 1] == ' ' and c[i - 2] == ' '
        emit(wide and ('\\quad\\text{' .. w .. '}\\quad ') or ('\\text{ ' .. w .. ' }'), false)
      elseif #w == 2 and w:match('^%l%l$') and not text_words then
        emit(w, true)                -- juxtaposed variables: ab, xy
      elseif text_words then emit(gap .. '\\text{' .. w .. '}', true)
      else emit(gap .. '\\mathrm{' .. w .. '}', true) end
      i = j
    elseif ch == '{' then emit('\\{', false); i = i + 1
    elseif ch == '}' then emit('\\}', true); i = i + 1
    elseif ch == '_' or ch == '^' then
      if c[i + 1] == '{' then        -- TeX-style group: x_{i,j}
        local depth, j = 1, i + 2
        while j <= n and depth > 0 do
          if c[j] == '{' then depth = depth + 1 elseif c[j] == '}' then depth = depth - 1 end
          j = j + 1
        end
        emit(ch .. '{' .. tex(table.concat(c, '', i + 2, j - 2)) .. '}', false); i = j
      elseif prev_atom and c[i + 1] and c[i + 1]:match('^%w$') then
        emit(ch, false); i = i + 1
      else emit(ch == '_' and '\\_' or '\\hat{}', true); i = i + 1 end
    elseif SUB[ch] or SUP[ch] then
      local map, mark = SUB[ch] and SUB or SUP, SUB[ch] and '_' or '^'
      local j, buf = i, {}
      while j <= n and map[c[j]] do buf[#buf + 1] = map[c[j]]; j = j + 1 end
      emit(mark .. '{' .. table.concat(buf) .. '}', true); i = j
    elseif ch == ':' then
      if c[i + 1] == '=' then emit('\\coloneqq ', false); i = i + 2
      elseif c[i - 1] == ' ' and c[i + 1] == ' ' then emit('\\colon ', false); i = i + 1
      else emit('{:}', false); i = i + 1 end
    elseif ch == '|' then emit('\\mid ', false); i = i + 1
    elseif ch == '*' then
      emit(prev_atom and '^{*}' or '\\ast ', true); i = i + 1
    elseif ch == '.' and c[i + 1] == '.' and c[i + 2] == '.' then
      emit('\\dots ', true); i = i + 3
    elseif ch == "'" then emit("'", true); i = i + 1
    elseif ch == '#' or ch == '%' or ch == '&' or ch == '$' then
      emit('\\' .. ch, true); i = i + 1
    elseif ch == '~' then emit('\\sim ', false); i = i + 1
    elseif ch == ' ' or ch == '\t' then emit(' ', prev_atom); i = i + 1
    elseif SYM[ch] then emit(SYM[ch], ch:match('[)%]]') ~= nil); i = i + 1
    elseif #ch > 1 then
      -- a non-ASCII character with no TeX equivalent above: in math mode
      -- pdflatex would print whatever glyph sits at that slot (± came out
      -- as ś), so set it as text instead and say so
      io.stderr:write('[mathdown] no math symbol for "' .. ch .. '" (U+' ..
        string.format('%04X', utf8.codepoint(ch)) .. '); add it to SYM\n')
      emit('\\text{' .. ch .. '}', true); i = i + 1
    else emit(ch, ch:match('^[%d%)%]]$') ~= nil); i = i + 1 end
  end
  return (table.concat(out):gsub('%s+', ' '):gsub('^ ', ''):gsub(' $', ''))
end

---------------------------------------------------------------------------
-- Display blocks
---------------------------------------------------------------------------

-- The relations a display is aligned on, in tiers of decreasing precedence.
-- A block aligns on the first tier that occurs in any of its lines, and each
-- line at its leftmost relation from that tier (outside brackets). So in
--   (x, y) ⊆ (x', y')  ⟺  (x + x', y + y') = (x', y')
--                      ⟺  x ⊆ x'  and  y ⊆ y'
-- the ⟺ wins over ⊆ and =. Anything not listed (<, ∈, ≠, …) is never used.
-- Override per document in the front matter, one list per tier:
--   mathdown-align: [["⟺", "⟹"], [":=", "=", "⊆", "⊑"]]
-- (a flat list is a single tier).
local RELS = {
  { '⟺', '⟹', '⟸', '⇔', '⇒', '⇐' },
  { ':=', '=', '≤', '⊆' },
}

local function sort_tier(t)
  -- longest first, so ":=" wins over "=" and "<=" over "<"
  table.sort(t, function(a, b) return #a > #b end)
  return t
end
for _, t in ipairs(RELS) do sort_tier(t) end

local ALL_RELS = {}
local function flatten_rels()
  ALL_RELS = {}
  for _, t in ipairs(RELS) do for _, r in ipairs(t) do ALL_RELS[#ALL_RELS + 1] = r end end
  sort_tier(ALL_RELS)
end
flatten_rels()

local align_pass = {
  Meta = function(meta)
    local a = meta['mathdown-align']
    if not a then return end
    RELS = {}
    local flat = {}
    for _, x in ipairs(a) do
      if type(x) == 'table' and x.t == nil or (type(x) == 'table' and x.t == 'MetaList') then
        local tier = {}
        for _, y in ipairs(x) do tier[#tier + 1] = stringify(y) end
        RELS[#RELS + 1] = sort_tier(tier)
      else
        flat[#flat + 1] = stringify(x)
      end
    end
    if #flat > 0 then RELS[#RELS + 1] = sort_tier(flat) end
    flatten_rels()
  end,
}

-- Logical arrows used for alignment get amsmath's wider spacing.
local WIDE = { ['⟺']='\\iff ', ['⇔']='\\iff ', ['⟹']='\\implies ',
  ['⇒']='\\implies ', ['⟸']='\\impliedby ', ['⇐']='\\impliedby ' }
local function rel_tex(r) return WIDE[r] or tex(r) end

-- Split at the first relation outside brackets: lhs, rel, rhs.
local function split_rel(s, rels)
  rels = rels or ALL_RELS
  local depth, i = 0, 1
  while i <= #s do
    local b = s:sub(i, i)
    if b:match('[%(%[{]') then depth = depth + 1
    elseif b:match('[%)%]}]') then depth = depth - 1
    elseif depth == 0 then
      for _, r in ipairs(rels) do
        if s:sub(i, i + #r - 1) == r then
          return trim(s:sub(1, i - 1)), r, trim(s:sub(i + #r))
        end
      end
    end
    i = i + 1
  end
end

-- "body    (justification)" → body, justification
local function split_just(line)
  local body, just = line:match('^(.-%S)%s%s+(%b())%s*$')
  if body then return body, just end
  return line, nil
end

local function starts_with_rel(seg)
  for _, r in ipairs(ALL_RELS) do
    if seg:sub(1, #r) == r then return true end
  end
  return false
end

-- Split a line into columns at runs of 3+ spaces. A segment that starts with
-- a relation is not a new column but the rest of the same equation, padded
-- to line up with the lines around it:  a:{}     = {}
local function split_cols(s)
  local cols, pos = {}, 1
  while true do
    local a, b = s:find('%s%s%s+', pos)
    local seg = a and s:sub(pos, a - 1) or s:sub(pos)
    if #cols > 0 and starts_with_rel(seg) then
      cols[#cols] = cols[#cols] .. ' ' .. seg
    else
      cols[#cols + 1] = seg
    end
    if not a then break end
    pos = b + 1
  end
  return cols
end

local function cases_block(lines)
  local lhs, rel, first = split_rel(trim(lines[1]))
  if not lhs then return nil end
  local rows = {}
  local function row(s)
    local val, cond = trim(s):match('^(.-)%s%s+if%s+(.+)$')
    if val then
      return tex(val) .. ' & \\text{if } ' .. tex(cond)
    end
    local v2 = trim(s):match('^(.-)%s%s+otherwise%s*$')
    if v2 then return tex(v2) .. ' & \\text{otherwise}' end
    return tex(s)
  end
  rows[1] = row(first)
  for k = 2, #lines do rows[#rows + 1] = row(lines[k]) end
  return '\\[\n  ' .. tex(lhs) .. ' ' .. tex(rel) ..
    ' \\begin{cases}\n    ' .. table.concat(rows, ' \\\\\n    ') .. '\n  \\end{cases}\n\\]'
end

local function group_to_tex(lines)
  for _, l in ipairs(lines) do
    if l:match('%S%s%s+if%s') then
      local t = cases_block(lines)
      if t then return t end
    end
  end

  -- The block aligns on the highest-precedence tier present in any line.
  local tier = nil
  for _, t in ipairs(RELS) do
    for _, line in ipairs(lines) do
      for _, col in ipairs(split_cols(trim((split_just(line))))) do
        if split_rel(col, t) then tier = t; break end
      end
      if tier then break end
    end
    if tier then break end
  end
  tier = tier or {}

  -- Each row: column pairs "lhs & rel rhs", then an optional justification.
  local parsed, maxcols, any_just, all_rel = {}, 0, false, true
  for _, line in ipairs(lines) do
    local body, just = split_just(line)
    local cols = split_cols(trim(body))
    local cells = {}
    for _, col in ipairs(cols) do
      local l, r, rest = split_rel(col, tier)
      if l then
        cells[#cells + 1] = tex(l) .. ' &' .. rel_tex(r) .. ' ' .. tex(rest)
      else
        cells[#cells + 1] = ' & ' .. tex(col)
        all_rel = false
      end
    end
    parsed[#parsed + 1] = { cells = cells, just = just }
    if #cells > maxcols then maxcols = #cells end
    if just then any_just = true end
  end

  if #lines == 1 and maxcols == 1 and not any_just then
    return '\\[\n  ' .. tex(trim(lines[1])) .. '\n\\]'
  end

  -- Only align when every line has a relation to align on. Otherwise the
  -- lines are separate formulas: centre each one.
  if not all_rel and not any_just then
    local rows = {}
    for _, line in ipairs(lines) do
      local cols = split_cols(trim(line))
      for k, c in ipairs(cols) do cols[k] = tex(c) end
      rows[#rows + 1] = table.concat(cols, ' \\qquad ')
    end
    return '\\begin{gather*}\n  ' .. table.concat(rows, ' \\\\\n  ') .. '\n\\end{gather*}'
  end

  -- alignat keeps columns and justifications close to the equations
  local rows = {}
  for _, p in ipairs(parsed) do
    local cells = p.cells
    while #cells < maxcols do cells[#cells + 1] = ' & ' end
    local row = table.concat(cells, ' &\\qquad ')
    if any_just then
      row = row .. ' &\\qquad & ' .. (p.just and tex(p.just, true) or '')
    end
    rows[#rows + 1] = row
  end
  local pairs_n = maxcols + (any_just and 1 or 0)
  return '\\begin{alignat*}{' .. pairs_n .. '}\n  ' ..
    table.concat(rows, ' \\\\\n  ') .. '\n\\end{alignat*}'
end

local function codeblock_to_tex(text)
  local groups, cur = {}, {}
  for line in (text .. '\n'):gmatch('(.-)\n') do
    if line:match('^%s*$') then
      if #cur > 0 then groups[#groups + 1] = cur; cur = {} end
    else cur[#cur + 1] = line end
  end
  if #cur > 0 then groups[#groups + 1] = cur end
  local out = {}
  for _, g in ipairs(groups) do out[#out + 1] = group_to_tex(g) end
  return table.concat(out, '\n')
end

local function is_math(el)
  return #el.classes == 0 or el.classes:includes('math')
end

-- Math symbols that appear in running text, e.g. "(⟹)".
local function str_math(s)
  local parts, buf = {}, {}
  local changed = false
  for _, ch in ipairs(chars(s)) do
    if SYM[ch] and ch ~= '…' and ch ~= '∎' and ch ~= '−' then
      if #buf > 0 then parts[#parts + 1] = pandoc.Str(table.concat(buf)); buf = {} end
      parts[#parts + 1] = pandoc.Math('InlineMath', tex(ch)); changed = true
    else buf[#buf + 1] = ch end
  end
  if not changed then return nil end
  if #buf > 0 then parts[#parts + 1] = pandoc.Str(table.concat(buf)) end
  return parts
end

local math_pass = {
  Code = function(el)
    if is_math(el) then return pandoc.Math('InlineMath', tex(el.text)) end
  end,
  CodeBlock = function(el)
    if is_math(el) then return pandoc.RawBlock('latex', codeblock_to_tex(el.text)) end
  end,
  Str = function(el) return str_math(el.text) end,
  -- Number lists (1), (2), … so references like "by (4)" match the labels.
  OrderedList = function(el)
    local la = el.listAttributes
    if la.style == 'DefaultStyle' or la.style == 'Decimal' then
      la.style = 'Decimal'
      la.delimiter = 'TwoParens'
      el.listAttributes = la
      return el
    end
  end,
}

---------------------------------------------------------------------------
-- Displays belong to the paragraph around them
---------------------------------------------------------------------------

local function is_display(b)
  return b.t == 'RawBlock' and b.format == 'latex'
    and (b.text:match('^\\%[') or b.text:match('^\\begin{align')
         or b.text:match('^\\begin{gather'))
end

-- A paragraph starts afresh after a display, list or quote, unless it begins
-- with "_ ": then it continues the paragraph before it.
--   … so that
--   ```
--   a = b
--   ```
--   _ which proves the claim.
-- Removes the marker and returns true if it was there.
local function take_continue(b)
  if not b or b.t ~= 'Para' or #b.content < 2 then return false end
  local m, sp = b.content[1], b.content[2]
  if m.t == 'Str' and m.text == '_' and (sp.t == 'Space' or sp.t == 'SoftBreak') then
    b.content:remove(1); b.content:remove(1)
    return true
  end
  return false
end

-- The paragraph a display should join: the previous paragraph, or the last
-- paragraph of the previous list item (a fence right after "- … Then").
local function host_of(prev)
  if not prev then return nil end
  if prev.t == 'Para' then return prev end
  if (prev.t == 'BulletList' or prev.t == 'OrderedList') and #prev.content > 0 then
    local item = prev.content[#prev.content]
    local lb = item[#item]
    if lb and (lb.t == 'Para' or lb.t == 'Plain') then return lb end
  end
  return nil
end

-- Para + display + "_ " Para  →  one paragraph, as in LaTeX source.
local function merge_displays(blocks)
  local out = pandoc.Blocks({})
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    if is_display(b) then
      local nxt = blocks[i + 1]
      local cont = take_continue(nxt)
      local host = host_of(out[#out])
      if host then
        host.content:insert(pandoc.RawInline('latex', '\n' .. b.text .. '\n'))
        if cont then host.content:extend(nxt.content); i = i + 1 end
      elseif cont then
        local p = pandoc.Para({ pandoc.RawInline('latex', '\\noindent\n' .. b.text .. '\n') })
        p.content:extend(nxt.content)
        out:insert(p)
        i = i + 1
      else
        out:insert(b)
      end
    elseif take_continue(b) then
      -- carries on after a list or quote: no paragraph indent
      b.content:insert(1, pandoc.RawInline('latex', '\\noindent '))
      out:insert(b)
    else
      out:insert(b)
    end
    i = i + 1
  end
  return out
end

-- Put the QED box on the last line of a proof that ends in a display.
local function qed_in_display(s)
  local r, n = s:gsub('\n\\end{alignat%*}(%s*)$', ' \\qedhere\n\\end{alignat*}%1')
  if n == 0 then r, n = s:gsub('\n\\%](%s*)$', ' \\qedhere\n\\]%1') end
  if n == 0 then r, n = s:gsub('\n\\end{gather%*}(%s*)$', ' \\qedhere\n\\end{gather*}%1') end
  return r, n > 0
end

local function close_proof(blocks)
  local last = blocks[#blocks]
  if last and last.t == 'Para' and #last.content > 0 then
    local tail = last.content[#last.content]
    if tail.t == 'RawInline' and tail.format == 'latex' then
      tail.text = qed_in_display(tail.text)
    end
    -- \end{proof} in the same paragraph keeps the box on the last line
    last.content:insert(pandoc.RawInline('latex', '\n\\end{proof}'))
  elseif last and is_display(last) then
    last.text = qed_in_display(last.text) .. '\n\\end{proof}'
  else
    blocks:insert(pandoc.RawBlock('latex', '\\end{proof}'))
  end
  return blocks
end

---------------------------------------------------------------------------
-- Theorem-like structure
---------------------------------------------------------------------------


local function raw(s) return pandoc.RawBlock('latex', s) end

-- Inlines → LaTeX, so math in a title stays math.
local function latex_of(inlines)
  return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), 'latex'))
end

local function begin_env(env, title)
  if title and title ~= '' then
    -- braces keep a "]" inside the title (e.g. math [x, y]) from ending the option
    return raw('\\begin{md' .. env .. '}[{' .. title .. '}]')
  end
  return raw('\\begin{md' .. env .. '}')
end

local function drop_leading_space(inlines)
  while #inlines > 0 and (inlines[1].t == 'Space' or inlines[1].t == 'SoftBreak'
                          or inlines[1].t == 'LineBreak') do
    inlines:remove(1)
  end
  return inlines
end

-- "**Theorem (Name):**" → "theorem", "Name"
local function theorem_head(block)
  if block.t ~= 'Para' or #block.content == 0 or block.content[1].t ~= 'Strong' then
    return nil
  end
  local s = latex_of(block.content[1].content)
  local name, rest = s:match('^(%a+)(.*)$')
  if not name or not ENVS[name:lower()] then return nil end
  rest = trim(rest):gsub('[:.]$', '')
  rest = trim(rest)
  local title = rest:match('^%((.*)%)$')
  if rest ~= '' and not title then return nil end
  return name:lower(), title
end

local function is_proof_start(block)
  if block.t ~= 'Para' or #block.content == 0 then return false end
  local first = block.content[1]
  if first.t ~= 'Emph' and first.t ~= 'Strong' then return false end
  return trim(stringify(first)):match('^Proof[.:]?$') ~= nil
end

local function has_qed(block) return stringify(block):find('∎', 1, true) ~= nil end

-- Remove ∎ from the last block of a proof. Returns nil if the block empties.
local function strip_qed(block)
  if block.t == 'Para' or block.t == 'Plain' then
    local inl = pandoc.Inlines({})
    for _, x in ipairs(block.content) do
      if x.t == 'Str' and x.text:find('∎', 1, true) then
        local rest = x.text:gsub('∎', '')
        if rest ~= '' then inl:insert(pandoc.Str(rest)) end
      else inl:insert(x) end
    end
    while #inl > 0 and (inl[#inl].t == 'Space' or inl[#inl].t == 'SoftBreak') do
      inl:remove(#inl)
    end
    if #inl == 0 then return nil end
    block.content = inl
    return block
  end
  -- ∎ nested in a list etc.: put the QED box on that line.
  return block:walk({
    Str = function(x)
      if x.text:find('∎', 1, true) then
        local rest = x.text:gsub('∎', '')
        return { pandoc.Str(rest), pandoc.RawInline('latex', '\\qedhere') }
      end
    end,
  })
end

-- A line inside a paragraph that starts with "*Proof.*" or a bold keyword
-- ("**Lemma.**") begins a new block, so these can be written compactly:
--   **Example (Powerset).** Let `S` be any set, …
--   *Proof.* …
--   ∎
local function starts_block(inlines, k)
  local probe = pandoc.Para({ inlines[k] })
  return is_proof_start(probe) or theorem_head(probe) ~= nil
end

local function split_paras(blocks)
  local out = pandoc.Blocks({})
  for _, b in ipairs(blocks) do
    if b.t == 'Para' then
      local cur = pandoc.Inlines({})
      for k, x in ipairs(b.content) do
        if (x.t == 'SoftBreak' or x.t == 'LineBreak') and b.content[k + 1]
            and starts_block(b.content, k + 1) then
          if #cur > 0 then out:insert(pandoc.Para(cur)) end
          cur = pandoc.Inlines({})
        else
          cur:insert(x)
        end
      end
      if #cur > 0 then out:insert(pandoc.Para(cur)) end
    else
      out:insert(b)
    end
  end
  return out
end

local function structure(blocks)
  blocks = merge_displays(split_paras(blocks))
  local out = pandoc.Blocks({})
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    local env, title = theorem_head(b)
    if env then
      b.content:remove(1)
      drop_leading_space(b.content)
      out:insert(begin_env(env, title))
      if #b.content > 0 then out:insert(b)
      elseif blocks[i + 1] then
        i = i + 1
        local nb = blocks[i]
        if nb.t ~= 'Para' and nb.t ~= 'Plain' then
          -- a list or display right after the head would run into it
          out:insert(raw('\\leavevmode\\vspace{-\\baselineskip}'))
        end
        out:insert(nb)
      end
      out:insert(raw('\\end{md' .. env .. '}'))
      i = i + 1
    elseif is_proof_start(b) then
      local j = i
      while j <= #blocks and not has_qed(blocks[j]) do j = j + 1 end
      if j > #blocks then j = i end
      b.content:remove(1)
      drop_leading_space(b.content)
      out:insert(raw('\\begin{proof}'))
      local body = pandoc.Blocks({})
      for k = i, j do
        local blk = blocks[k]
        if k == j then blk = strip_qed(blk) end
        if blk and not (blk.t == 'Para' and #blk.content == 0) then body:insert(blk) end
      end
      out:extend(close_proof(merge_displays(body)))
      i = j + 1
    else
      out:insert(b)
      i = i + 1
    end
  end
  return out
end

return {
  align_pass,
  math_pass,
  { Pandoc = function(doc) doc.blocks = structure(doc.blocks); return doc end },
}
