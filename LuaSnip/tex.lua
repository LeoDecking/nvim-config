local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep
local line_begin = require('luasnip.extras.expand_conditions').line_begin

local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
local cap1 = function(_, snip)
  return snip.captures[1] or ''
end
local cap2 = function(_, snip)
  return snip.captures[2] or ''
end
local tex_utils = {}
-- tex_utils.in_mathzone = function() -- math context detection
--   return vim.fn['vimtex#syntax#in_mathzone']() == 1
-- end

tex_utils.in_mathzone = function()
  if vim.bo.filetype == 'tex' then
    -- Use VimTeX for .tex files
    return vim.fn['vimtex#syntax#in_mathzone']() == 1
  elseif vim.bo.filetype == 'markdown' then
    -- Use Treesitter for markdown files
    local ts_utils = require 'nvim-treesitter.ts_utils'
    local node = ts_utils.get_node_at_cursor()
    while node do
      if node:type() == 'inline_formula' or node:type() == 'inline_equation' or node:type() == 'displayed_equation' then
        return true
      end
      node = node:parent()
    end
    return false
  end
  return false
end

tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_markdown = function()
  return vim.bo.filetype == 'markdown' and not tex_utils.in_mathzone()
end
tex_utils.in_comment = function() -- comment detection
  return vim.fn['vimtex#syntax#in_comment']() == 1
end
tex_utils.in_env = function(name) -- generic environment detection
  local is_inside = vim.fn['vimtex#env#is_inside'](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function() -- equation environment detection
  return tex_utils.in_env 'equation'
end
tex_utils.in_itemize = function() -- itemize environment detection
  return tex_utils.in_env 'itemize'
end
tex_utils.in_tikz = function() -- TikZ picture environment detection
  return tex_utils.in_env 'tikzpicture'
end
tex_utils.empty_line_above_md = function()
  if vim.bo.filetype ~= 'markdown' then
    return false
  end
  local line_num = vim.fn.line '.' - 2 -- current line is 1-based, subtract 2 to get line above
  if line_num < 0 then
    return true -- at top of file, treat as empty
  end
  local line = vim.fn.getline(line_num + 1) -- get line content
  return line == '' -- true if empty
end
local mat = function(args, snip)
	local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j).."x1", i(1)))
		ins_indx = ins_indx+1
		for k = 2, cols do
			table.insert(nodes, t" & ")
			table.insert(nodes, r(ins_indx, tostring(j).."x"..tostring(k), i(1)))
			ins_indx = ins_indx+1
		end
		table.insert(nodes, t{"\\\\", ""})
	end
	return sn(nil, nodes)
end

return {
  s({ trig = '*', condition = tex_utils.in_markdown, wordTrig = false, snippetType = 'autosnippet' }, fmta('*<>*', { d(1, get_visual) })),
  s({ trig = '^>>', condition = tex_utils.in_markdown, wordTrig = false, regTrig = true, snippetType = 'autosnippet' }, fmt('**{}** >> {}', { i(1), i(2) })),
  s(
    { trig = '^?', condition = tex_utils.empty_line_above_md, wordTrig = false, regTrig = true, snippetType = 'autosnippet' },
    fmt('**{}**\n?\n{}\n', { i(1), i(2) })
  ),
  s(
    { trig = '\\mbb', dscr = "Expands 'mbb;' into LaTeX's mathbb{} command.", condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' },
    fmta('\\mathbb{<>}', { i(1) })
  ),
  s({ trig = '\\mbE', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\mathbb{E}\\left[<>\\right]', { i(1) })),
  s({ trig = '\\mbP', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\mathbb{P}\\left[<>\\right]', { i(1) })),
  s({ trig = '\\mb(%u)', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet', regTrig = true }, fmta('\\mathbb{<>}', { f(cap1) })),
  s(
    {
      trig = '\\mcO',
      wordTrig = false,
      dscr = 'big O',
      snippetType = 'autosnippet',
      hidden = false,
    },
    fmta('\\mathcal{O}\\left(<>\\right)', {
      i(1),
    })
  ),
  s(
    { trig = '\\mc(%u)', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet', regTrig = true },
    fmta('\\mathcal{<>}', { f(cap1) })
  ),
  s(
    { trig = '\\mcc', dscr = "Expands 'mc;' into LaTeX's mathcal{} command.", condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' },
    fmta('\\mathcal{<>}', { i(1) })
  ),
  s({ trig = '\\cdot *', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\star', {})),
  s({ trig = '*', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\cdot ', {})),
  s({ trig = '\\inn', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\in ', {})),
  s({ trig = '\\inb', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\in \\mathbb{<>}', { i(1) })),
  s({ trig = '\\ee', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\varepsilon', {})),
  -- s({ trig = '(', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('(<>)', { d(1, get_visual) })),
  s({ trig = '\\(', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\left(<>\\right)', { d(1, get_visual) })),
  s({ trig = 'mm', dscr = '$..$', condition = tex_utils.in_text, wordTrig = true, snippetType = 'autosnippet' }, fmta('$<>$ ', { d(1, get_visual) })),
  s({ trig = 'aa', condition = line_begin, wordTrig = true, snippetType = 'autosnippet' }, fmta('$$\n\\begin{align*}\n\t<>\n\\end{align*}\n$$\n ', { d(1, get_visual) })),
  s({ trig = 'nn', condition = line_begin, wordTrig = true, snippetType = 'autosnippet' }, fmta('$$\n<>\n$$\n ', { d(1, get_visual) })),
  s(
    { trig = '([^%w])m,([%w])', condition = tex_utils.in_text, wordTrig = false, snippetType = 'autosnippet', regTrig = true },
    fmta('<>$<>$ ', { f(cap1), f(cap2) })
  ),
  s({ trig = '$ (%p)', condition = tex_utils.in_text, wordTrig = false, snippetType = 'autosnippet', regTrig = true }, fmta('$<>', { f(cap1) })),
  s({ trig = '$  ', condition = tex_utils.in_text, wordTrig = false, snippetType = 'autosnippet', regTrig = true }, fmta('$ ', {})),
  -- s({ trig = '$ \n', condition = tex_utils.in_text, wordTrig = false, snippetType = 'autosnippet', regTrig = true }, fmta('$\n', {})),
  -- s({ trig = '_', dscr = 'Underscore', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('_{<>}', { i(1) })),
  s({ trig = '__', dscr = 'Underscore', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('_{<>}', { i(1) })),
  s({ trig = '⁰', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{0<>}', { i(1) })),
  s({ trig = '\\sqq', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{2}', {  })),
  s({ trig = '²', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{2<>}', { i(1) })),
  s({ trig = '³', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{3<>}', { i(1) })),
  s({ trig = '⁻', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{-<>}', { i(1) })),
  s({ trig = 'î', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{i<>}', { i(1) })),
  s({ trig = '^', dscr = 'Caret', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{<>}', { i(1) })),
  s({ trig = '°', dscr = 'Caret', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{<>}', { i(1) })),
  s({ trig = '\\T', dscr = 'Caret', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^T', {  })),
  s({ trig = '\\sqrt', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\sqrt{<>}', { i(1) })),
  s({ trig = '\\es', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\emptyset', {})),
  s({ trig = '\\cap', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\cap ', {})),
  s({ trig = '\\cup', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\cup ', {})),
  s({ trig = '\\ol', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\overline{<>} ', { d(1, get_visual) })),
  s({ trig = '\\Tr', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('Tr\\left[<>\\right]', { i(1) })),
  s({ trig = '\\ket', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\ket{<>}', { i(1) })),
  s({ trig = '\\bra', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\bra{<>}', { i(1) })),
  s({ trig = '\\bket', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\braket{<>|<>}', { i(1), i(2) })),
  s({ trig = '\\kbra', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\ket{<>}\\bra{<>}', { i(1), rep(1) })),
  s({ trig = '\\|', condition = tex_utils.in_mathzone, word_Trig = false, snippetType = 'autosnippet' }, fmta('\\|<>\\|', { i(1) })),
  -- s({ trig = '|', condition = tex_utils.in_mathzone, word_Trig = false, snippetType = 'autosnippet' }, fmta('|<>|', { i(1) })),
  s({ trig = '\\tilde', condition = tex_utils.in_mathzone, word_trig = false, snippetType = 'autosnippet' }, fmta('\\tilde{<>}', { d(1, get_visual) })),
  s({ trig = '\\quad', condition = tex_utils.in_mathzone, word_trig = false, snippetType = 'autosnippet' }, fmta('\\quad ', {})),
  s({trig='\\&', condition = tex_utils.in_mathzone, word_trig=false, snippetType='autosnippet'}, fmta('&\\overset{}{\\qquad<>\\qquad} ', {i(1)})),
  s({trig='&\\os', condition = tex_utils.in_mathzone, word_trig=false, snippetType='autosnippet'}, fmta('&\\overset{<>}{\\qquad<>\\qquad} ', {i(1),i(2)})),
  s({trig='\\os', condition = tex_utils.in_mathzone, word_trig=false, snippetType='autosnippet'}, fmta('\\overset{<>}{<>}', {i(1),i(2)})),
  s({ trig = '\\ t t', condition = tex_utils.in_mathzone, word_trig = false, snippetType = 'autosnippet' }, fmta('\\text{ <> }', { d(1, get_visual) })),
  s({ trig = '\\t t', condition = tex_utils.in_mathzone, word_trig = false, snippetType = 'autosnippet' }, fmta('\\text{<> }', { d(1, get_visual) })),
  -- s({ trig = '\\tc', condition = tex_utils.in_mathzone(), word_trig = false, snippetType = 'autosnippet' }, fmta('\\textsc{<>}', { d(1, get_visual) })),
  s({ trig = '\\tt', condition = tex_utils.in_mathzone, word_trig = false, snippetType = 'autosnippet' }, fmta('\\text{<>}', { d(1, get_visual) })),
  s({ trig = '\\{', condition = tex_utils.in_mathzone, word_trig = false, snippetType = 'autosnippet' }, fmta('\\{<>\\}', { d(1, get_visual) })),
  s(
    { trig = '\\ff', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false },
    fmta('\\frac{<>}{<>}', { i(1, 'numerator'), i(2, 'denominator') })
  ),
  s({ trig = '{\\dg', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false }, fmta('{\\dagger', {})),
  s(
    { trig = '([^\\{])\\dg', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false, regTrig = true },
    fmta('<>^{\\dagger}', { f(cap1) })
  ),
  s({ trig = '\\maxl', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false }, fmta('\\max\\limits_{<>}', { i(1) })),
  s({ trig = '\\minl', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false }, fmta('\\min\\limits_{<>}', { i(1) })),
  s({ trig = '\\sl', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false }, fmta('\\sum\\limits_{<>}', { i(1) })),
  s({ trig = '\\pl', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false }, fmta('\\prod\\limits_{<>}', { i(1) })),
  s({ trig = '\\cref', condition = tex_utils.in_text, snippetType = 'autosnippet', wordTrig = false }, fmta('\\cref{<>}', { i(1) })),
  s({ trig = '\\cite', condition = tex_utils.in_text, snippetType = 'autosnippet', wordTrig = false }, fmta('\\cite{<>}', { i(1) })),
  s({ trig = '\\emph', condition = tex_utils.in_text, snippetType = 'autosnippet', wordTrig = false }, fmta('\\emph{<>}', { i(1) })),
  s({ trig = 'h1', dscr = 'Start a new section', condition = line_begin, snippetType = 'autosnippet' }, fmta('\\section{<>}', { i(1, 'Section Title') })),
  s({ trig = 'tii', dscr = "Expands 'tii' into LaTeX's textit{} command." }, fmta('\\textit{<>}', { d(1, get_visual) })),
  s(
    { trig = 'env', dscr = "Expands 'env' into LaTeX's environment command.", condition = line_begin, snippetType = 'autosnippet' },
    fmta('\\begin{<>}\n\t<>\n\\end{<>}', { i(1), i(2), rep(1) })
  ),
  s({ trig = 'align', condition = line_begin, snippetType = 'autosnippet' }, fmta('\\begin{align*}\n\t<>\n\\end{align*}', { i(1) })),
  s({ trig='\\([pb])mat(%d+)x(%d+)([ar])', wordTrig=false,regTrig=true,  condition = tex_utils.in_mathzone, snippetType='autosnippet',name='matrix', dscr='matrix trigger lets go'},
    fmt([[\left<>\begin{array}<>
    <>\end{array}\right<>]],
    { f(function (_, snip) return (snip.captures[1]=="p") and "(" or "[" end),
    f(function (_, snip) -- augments
        if snip.captures[4] == "a" then
            out = string.rep("c", tonumber(snip.captures[3]) - 1)
            return "{" .. out .. "|c}"
        end
        return "\\"
    end),
    d(1, mat),
    f(function (_, snip) return (snip.captures[1]=="p") and ")" or "]" end)},
    { delimiters='<>' }
    ))
}
