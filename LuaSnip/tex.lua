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
tex_utils.in_mathzone = function() -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
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

return {
  s(
    { trig = '\\mbb', dscr = "Expands 'mbb;' into LaTeX's mathbb{} command.", condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' },
    fmta('\\mathbb{<>}', { i(1) })
  ),
  s({ trig = '\\mbE', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\mathbb{E}\\left[<>\\right]', { i(1) })),
  s({ trig = '\\mbP', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\mathbb{P}\\left[<>\\right]', { i(1) })),
  s({ trig = '\\mb(%u)', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet', regTrig = true }, fmta('\\mathbb{<>}', { f(cap1) })),
  s(
    { trig = '\\mc(%u)', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet', regTrig = true },
    fmta('\\mathcal{<>}', { f(cap1) })
  ),
  s(
    { trig = '\\mcc', dscr = "Expands 'mc;' into LaTeX's mathcal{} command.", condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' },
    fmta('\\mathcal{<>}', { i(1) })
  ),
  s({ trig = '*', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\cdot ', {})),
  s({ trig = '\\inn', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\in ', {})),
  s({ trig = '\\inb', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\in \\mathbb{<>}', { i(1) })),
  s({ trig = '\\ee', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\varepsilon', {})),
  -- s({ trig = '(', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('(<>)', { d(1, get_visual) })),
  s({ trig = '\\(', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('\\left(<>\\right)', { d(1, get_visual) })),
  s({ trig = 'mm', dscr = '$..$', condition = tex_utils.in_text, wordTrig = true, snippetType = 'autosnippet' }, fmta('$<>$ ', { d(1, get_visual) })),
  s({ trig = 'nn', condition = line_begin, wordTrig = true, snippetType = 'autosnippet' }, fmta('$$\n\t<>\n$$\n ', { d(1, get_visual) })),
  s(
    { trig = '([^%w])m,([%w])', condition = tex_utils.in_text, wordTrig = false, snippetType = 'autosnippet', regTrig = true },
    fmta('<>$<>$ ', { f(cap1), f(cap2) })
  ),
  s({ trig = '$ (%p)', condition = tex_utils.in_text, wordTrig = false, snippetType = 'autosnippet', regTrig = true }, fmta('$<>', { f(cap1) })),
  s({ trig = '$  ', condition = tex_utils.in_text, wordTrig = false, snippetType = 'autosnippet', regTrig = true }, fmta('$ ', {})),
  s({ trig = '_', dscr = 'Underscore', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('_{<>}', { i(1) })),
  s({ trig = '^', dscr = 'Caret', condition = tex_utils.in_mathzone, wordTrig = false, snippetType = 'autosnippet' }, fmta('^{<>}', { i(1) })),
  s({ trig = '|', condition = tex_utils.in_mathzone, word_Trig = false, snippetType = 'autosnippet' }, fmta('|<>|', { i(1) })),
  s({ trig = '\\{', condition = tex_utils.in_mathzone(), word_trig = false, snippetType = 'autosnippet' }, fmta('\\{<>\\}', { d(1, get_visual) })),
  s(
    { trig = '\\ff', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false },
    fmta('\\frac{<>}{<>}', { i(1, 'numerator'), i(2, 'denominator') })
  ),
  s({ trig = '{\\dg', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false }, fmta('{\\dagger', {})),
  s(
    { trig = '([^\\{])\\dg', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false, regTrig = true },
    fmta('<>^{\\dagger}', { f(cap1) })
  ),
  s({ trig = '\\sl', condition = tex_utils.in_mathzone, snippetType = 'autosnippet', wordTrig = false }, fmta('\\sum\\limits_{<>}', { i(1) })),
  s({ trig = '\\cref', condition = tex_utils.in_text, snippetType = 'autosnippet', wordTrig = false }, fmta('\\cref{<>}', { i(1) })),
  s({ trig = '\\cite', condition = tex_utils.in_text, snippetType = 'autosnippet', wordTrig = false }, fmta('\\cite{<>}', { i(1) })),
  s(
    {
      trig = '([^%a])bo;',
      regTrig = true,
      wordTrig = false,
      dscr = 'big O',
      snippetType = 'autosnippet',
      hidden = false,
    },
    fmta('<>\\mathcal{O}\\left(<>\\right)', {
      f(cap1),
      i(1),
    })
  ),
  s({ trig = 'h1', dscr = 'Start a new section', condition = line_begin, snippetType = 'autosnippet' }, fmta('\\section{<>}', { i(1, 'Section Title') })),
  s({ trig = 'tii', dscr = "Expands 'tii' into LaTeX's textit{} command." }, fmta('\\textit{<>}', { d(1, get_visual) })),
  s(
    { trig = 'env', dscr = "Expands 'env' into LaTeX's environment command.", condition = line_begin, snippetType = 'autosnippet' },
    fmta('\\begin{<>}\n\t<>\n\\end{<>}', { i(1), i(2), rep(1) })
  ),
}
