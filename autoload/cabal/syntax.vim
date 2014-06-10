" Copyright (c) 2014 Ian D. Bollinger
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

let s:bundle = fn#bundle#Get('cabal')

""
"
function! cabal#syntax#FieldNames() abort
  return keys(fn#bundle#GetFlag(s:bundle, 'syntax_fields'))
endfunction

""
"
function! cabal#syntax#KeywordPattern() abort
  return '\v[[:alpha:]][[:alnum:]-]*'
endfunction

""
"
function! cabal#syntax#InsideComment() abort
  return fn#syntax#NameAtCursor() =~# 'Comment'
endfunction

""
"
function! cabal#syntax#Keywords() abort
  return cabal#syntax#FieldNames()
      \ + fn#bundle#GetFlag(s:bundle, 'syntax_sections')
      \ + fn#bundle#GetFlag(s:bundle, 'syntax_build_types')
      \ + fn#bundle#GetFlag(s:bundle, 'syntax_licenses')
      \ + fn#bundle#GetFlag(s:bundle, 'syntax_test_suite_types')
endfunction

""
" Entry point for the syntax highlighter for Cabal package descriptions.
function! cabal#syntax#Main() abort
  call fn#syntax#Highlighter('cabal', function('s:Inner'))
endfunction

""
"
function! cabal#syntax#FoldText() abort
  return getline(v:foldstart) . ' '
endfunction

function! s:Inner() abort
  syntax include @Haskell syntax/haskell.vim
  call s:DefinePatterns()
  call s:SetLocalVimOptions()
  call s:DefineKeywords()
  call s:DefineMatches()
  call s:DefineFields()
  call cabal#haddock#Main()
  call s:DefineRegions()
  call s:DefineLinks()
endfunction

function! s:DefinePatterns() abort
  let l:separator = '\s*,?\s*'
  let l:free_form = '.*'
  let l:version = '\d+%(\.%(\d)+)*'
  let l:build_type = escape(
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_build_types')),
      \ '.',
      \ )
  let l:token = '%([^"][^[:space:],]*|"[^"]+")'
  let l:license =
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_licenses'))
  let l:language =
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_languages'))
  let l:module = fn#pattern#SepBy1('[[:upper:]][[:alnum:]_'']*', '.')
  let l:type = escape(
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_test_suite_types')),
      \ '.'
      \ )
  let l:token_list = fn#pattern#SepBy1(l:token, l:separator)
  let l:compiler =
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_compilers'))
  let l:compiler_list = fn#pattern#SepBy1(
      \ l:compiler . '%(\s*%(\>\=?|\<\=?|\=\=)\s*' . l:version . ')?',
      \ l:separator,
      \ )
  let g:cabal_syntax_patterns = {
      \ 'free_form': l:free_form,
      \ 'version': l:version,
      \ 'boolean': fn#pattern#Choice(['True', 'False']),
      \ 'build_type': l:build_type,
      \ 'token': l:token,
      \ 'license': l:license,
      \ 'package': '[[:alpha:]][a-zA-Z0-9-]*',
      \ 'type': l:type,
      \ 'language': l:language,
      \ 'module': l:module,
      \ 'compiler_list': l:compiler_list,
      \ 'token_list': l:token_list,
      \ 'module_list': fn#pattern#SepBy1(l:module, l:separator),
      \ 'cabal_version': '\>\=\s*' . l:version,
      \
      \ 'package_list': l:token_list,
      \ 'extension_list': l:token_list,
      \ 'program_list': l:token_list,
      \ 'pkgconfig': l:token_list,
      \ 'url': l:free_form,
      \ }
endfunction

function! s:SetLocalVimOptions() abort
  setlocal commentstring=--%s
  setlocal iskeyword=a-z,A-Z,48-57,-
  setlocal foldmethod=syntax
  setlocal foldtext=cabal#syntax#FoldText()
endfunction

function! s:DefineKeywords() abort
  call fn#dict#Map_(function('fn#syntax#Keyword'), {
      \ 'cabalTodo': fn#bundle#GetFlag(s:bundle, 'syntax_todo'),
      \ 'cabalSectionName': fn#bundle#GetFlag(s:bundle, 'syntax_sections'),
      \ 'cabalFieldName': cabal#syntax#FieldNames(),
      \ 'cabalFunction': ['arch', 'flag', 'impl', 'os'],
      \ 'cabalConditional': ['else', 'if'],
      \ 'cabalBoolean': ['False', 'True'],
      \ 'cabalCompiler': fn#bundle#GetFlag(s:bundle, 'syntax_compilers'),
      \ })
endfunction

function! s:DefineMatches() abort
  call fn#syntax#Match('cabalComment', '^\s*--.*$', {
      \ 'contains': ['cabalTodo', '@Spell'],
      \ })
  call fn#syntax#Match(
      \ 'cabalOperator',
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_operators')),
      \ {'contained': 1, 'display': 1}
      \ )
  call fn#syntax#Match('cabalInvalidValue', '.*$', {'contained': 1})
endfunction

function! s:DefineFields() abort
  call fn#dict#Map_(
      \ function('s:DefineField'),
      \ fn#bundle#GetFlag(s:bundle, 'syntax_fields')
      \ )
endfunction

function! s:DefineRegions() abort
  call fn#syntax#Match(
      \ 'cabalEmptyField',
      \ '^(\s*)[^-].{-}\s*:\s*(\n\1)*(%$|\n[^ ])')
  call fn#syntax#Region(
      \ 'cabalIdentifier',
      \ '\c^' . fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_sections')),
      \ '$', {
        \ 'matchgroup': 'cabalSection',
        \ 'display': 1,
        \ 'oneline': 1,
        \ 'contains': 'cabalSectionName',
        \ })
  call fn#syntax#Region(
      \ 'cabalIdentifier',
      \ fn#pattern#Choice(['os', 'arch', 'impl', 'flag']) . '\(',
      \ '\)', {
        \ 'matchgroup': 'cabalKeyword',
        \ 'display': 1,
        \ 'oneline': 1,
        \ 'contained': 1,
        \ 'contains': 'cabalIdentifier',
        \ })
  call fn#syntax#Region(
      \ 'cabalIdentifier',
      \ '\c^\s*' . fn#pattern#Choice(['if', 'else']),
      \ '$', {
        \ 'matchgroup': 'cabalConditional',
        \ 'display': 1,
        \ 'oneline': 1,
        \ 'contains': ['cabalIdentifier', 'cabalBoolean'],
        \ })
  call fn#syntax#Region(
      \ 'cabalFold',
      \ '\c^' . fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_sections')) . '>',
      \ '\ze^\S', {
        \ 'skip': '^--',
        \ 'transparent': 1,
        \ 'fold': 1,
        \ })
  call fn#syntax#Match(
      \ 'cabalCompiler',
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_compilers')),
      \ {'contained': 1, 'display': 1}
      \ )
  call fn#syntax#Match(
      \ 'cabalVersion',
      \ g:cabal_syntax_patterns.version,
      \ {'contained': 1, 'display': 1}
      \ )
endfunction

function! s:DefineLinks() abort
  let l:links = extend({
      \ 'cabalCompiler': 'cabalEnum',
      \ 'cabalEmptyField': 'Error',
      \ 'cabalInvalidValue': 'Error',
      \ 'cabalUrl': 'Underlined',
      \ 'cabalTodo': 'Todo',
      \ 'cabalEnum': 'Type',
      \ 'cabalPackage': 'Type',
      \ 'cabalOperator': 'Operator',
      \ 'cabalBoolean': 'Boolean',
      \ 'cabalVersion': 'Number',
      \ 'cabalComment': 'Comment',
      \ 'cabalField': 'Define',
      \ 'cabalDelimiter': 'Delimiter',
      \ 'cabalIdentifier': 'Identifier',
      \ 'cabalSection': 'Statement',
      \ 'cabalKeyword': 'Keyword',
      \ 'cabalConditional': 'Conditional',
      \ 'cabalString': 'String',
      \ 'cabalUnderlined': 'Underlined',
      \ }, cabal#haddock#Links())
  call fn#dict#Map_(function('fn#syntax#Link'), l:links)
endfunction

function! s:DefineField(field, value) abort
  let l:formatted_name = 'cabal' . s:StripHyphens(a:field)
  let l:field_group = l:formatted_name . 'Field'
  let l:value_group = l:formatted_name . 'Value'
  let l:field_pattern = s:FieldPattern(a:field)
  let l:field_options = s:FieldOptions(a:value, l:value_group)
  call fn#syntax#Match(l:field_group, l:field_pattern, l:field_options)
  let l:value_options = {'contained': 1}
  if has_key(a:value, 'contains')
    let l:value_options.contains = a:value.contains
  endif
  let l:value_pattern = s:ValuePattern(a:value)
  call fn#syntax#Match(l:value_group, l:value_pattern, l:value_options)
  call fn#syntax#Link(l:field_group, 'cabalField')
  if has_key(a:value, 'link')
    call fn#syntax#Link(l:value_group, a:value.link)
  endif
endfunction

function! s:FieldOptions(value, value_group) abort
  let l:next_groups = [a:value_group]
  if !has_key(a:value, 'no-errors')
    call add(l:next_groups, 'cabalInvalidValue')
  endif
  return {'display': 1, 'nextgroup': l:next_groups}
endfunction

function! s:FieldPattern(field) abort
  return '\c^\s*' . a:field . '\s*:\s*'
endfunction

function! s:ValuePattern(value) abort
  return a:value.pattern is# 'free_form'
      \ ? '.*\n%((\s+).*%(\n\1.*)*)='
      \ : g:cabal_syntax_patterns[a:value.pattern] . '\s*$'
endfunction

function! s:StripHyphens(string) abort
  return substitute(a:string, '-', '', 'g')
endfunction

