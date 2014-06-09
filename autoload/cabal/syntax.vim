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
  if !exists('b:current_syntax')
    call fn#WithDefaultCompatibilityOptions(function('s:Inner'))
    let b:current_syntax = 'cabal'
  endif
endfunction

function! s:Inner() abort
  syntax include @Haskell syntax/haskell.vim
  call s:DefineConstants()
  call s:SetLocalVimOptions()
  call s:DefineKeywords()
  call s:DefineMatches()
  call s:DefineFields()
  call cabal#haddock#Main()
  call s:DefineRegions()
  call s:DefineLinks()
endfunction

""
"
function! cabal#syntax#Keyword(group_name, keywords, ...) abort
  let l:options = a:0 > 0 ? a:1 : {}
  if !has_key(l:options, 'contained')
    let l:options.contained = 1
  endif
  call fn#Execute(
      \ 'syntax keyword',
      \ s:match_group_prefix . a:group_name,
      \ s:FormatOptions(l:options),
      \ join(a:keywords),
      \ )
endfunction

""
"
function! cabal#syntax#Match(group_name, pattern, ...) abort
  let l:options = a:0 > 0 ? s:FormatOptions(a:1) : ' '
  let l:match_group = s:match_group_prefix . a:group_name
  let l:pattern = s:Pattern(a:pattern)
  call fn#Execute('syntax match', l:match_group, l:options, l:pattern)
endfunction

""
"
function! cabal#syntax#Region(group_name, start, end, ...) abort
  let l:options = a:0 > 0 ? s:FormatOptions(a:1) : ' '
  let l:match_group = s:match_group_prefix . a:group_name
  let l:start = 'start=' . s:Pattern(a:start)
  let l:end = 'end=' . s:Pattern(a:end)
  call fn#Execute('syntax region', l:match_group, l:start, l:end, l:options)
endfunction

""
"
function! cabal#syntax#FoldText() abort
  return getline(v:foldstart) . ' '
endfunction

function! s:DefineConstants() abort
  let s:match_group_prefix = 'cabal'

  let g:cabal_syntax_patterns = {
      \ 'free_form': '.*',
      \ 'version': '\d+%(\.%(\d)+)*',
      \ 'boolean': fn#pattern#Choice(['True', 'False']),
      \ 'build_type':
        \ escape(fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_build_types')), '.'),
      \ 'token': '%([^"][^[:space:],]*|"[^"]+")',
      \ 'license': fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_licenses')),
      \ 'package': '[[:alpha:]][a-zA-Z0-9-]*',
      \ 'type':
        \ escape(fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_test_suite_types')), '.'),
      \
      \ 'identifier': '[[:alpha:]][a-zA-Z0-9_]*'
      \ }

  call extend(g:cabal_syntax_patterns, {
      \ 'token_list':
        \ fn#pattern#SepBy1(g:cabal_syntax_patterns.token, '\s*,=\s*'),
      \ 'cabal_version': '\>\=\s*' . g:cabal_syntax_patterns.version,
      \
      \ 'url': g:cabal_syntax_patterns.free_form,
      \ 'compiler_list': g:cabal_syntax_patterns.free_form,
      \ 'language': g:cabal_syntax_patterns.token,
      \ })

   call extend(g:cabal_syntax_patterns, {
      \ 'identifier_list': g:cabal_syntax_patterns.token_list,
      \ 'package_list': g:cabal_syntax_patterns.token_list,
      \ 'extension_list': g:cabal_syntax_patterns.token_list,
      \ 'program_list': g:cabal_syntax_patterns.token_list,
      \ 'pkgconfig': g:cabal_syntax_patterns.token_list,
      \ })
endfunction

function! s:SetLocalVimOptions() abort
  setlocal commentstring=--%s
  setlocal iskeyword=a-z,A-Z,48-57,-
  setlocal foldmethod=syntax
  setlocal foldtext=cabal#syntax#FoldText()
endfunction

function! s:DefineKeywords() abort
  call fn#dict#Map_(function('cabal#syntax#Keyword'), {
      \ 'Todo': fn#bundle#GetFlag(s:bundle, 'syntax_todo'),
      \ 'SectionName': fn#bundle#GetFlag(s:bundle, 'syntax_sections'),
      \ 'FieldName': cabal#syntax#FieldNames(),
      \ 'Function': ['arch', 'flag', 'impl', 'os'],
      \ 'Conditional': ['else', 'endif', 'if'],
      \ 'Boolean': ['False', 'True'],
      \ 'Compiler': fn#bundle#GetFlag(s:bundle, 'syntax_compilers'),
      \ })
endfunction

function! s:DefineMatches() abort
  call cabal#syntax#Match('Comment', '^\s*--.*$', {
      \ 'contains': [s:match_group_prefix . 'Todo', '@Spell'],
      \ })
  call cabal#syntax#Match(
      \ 'Operator',
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_operators')),
      \ {'contained': 1, 'display': 1}
      \ )
  call cabal#syntax#Match('InvalidValue', '.*$', {'contained': 1})
endfunction

function! s:DefineFields() abort
  call fn#dict#Map_(
      \ function('s:DefineField'),
      \ fn#bundle#GetFlag(s:bundle, 'syntax_fields')
      \ )
endfunction

function! s:DefineRegions() abort
  call cabal#syntax#Match(
      \ 'EmptyField',
      \ '^(\s*)[^-].{-}\s*:\s*(\n\1)*(%$|\n[^ ])')
  call cabal#syntax#Region(
      \ 'Identifier',
      \ '\c^' . fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_sections')),
      \ '$', {
        \ 'matchgroup': 'Section',
        \ 'display': 1,
        \ 'oneline': 1,
        \ 'contains': s:match_group_prefix . 'SectionName',
        \ })
  call cabal#syntax#Region(
      \ 'Identifier',
      \ fn#pattern#Choice(['os', 'arch', 'impl', 'flag']) . '\(',
      \ '\)', {
        \ 'matchgroup': 'Keyword',
        \ 'display': 1,
        \ 'oneline': 1,
        \ 'contained': 1,
        \ 'contains': s:match_group_prefix . 'Identifier',
        \ })
  call cabal#syntax#Region(
      \ 'Identifier',
      \ '\c^\s*' . fn#pattern#Choice(['if', 'else', 'endif']),
      \ '$', {
        \ 'matchgroup': 'Conditional',
        \ 'display': 1,
        \ 'oneline': 1,
        \ 'contains': [
          \ s:match_group_prefix . 'Identifier',
          \ s:match_group_prefix . 'Boolean'
          \ ],
        \ })
  call cabal#syntax#Region(
      \ 'Fold',
      \ '\c^' . fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_sections')) . '>',
      \ '\ze^\S', {
        \ 'skip': '^--',
        \ 'transparent': 1,
        \ 'fold': 1,
        \ })
  call cabal#syntax#Match(
      \ 'Compiler',
      \ fn#pattern#Choice(fn#bundle#GetFlag(s:bundle, 'syntax_compilers')),
      \ {'contained': 1, 'display': 1}
      \ )
  call cabal#syntax#Match(
      \ 'Version',
      \ g:cabal_syntax_patterns.version,
      \ {'contained': 1, 'display': 1}
      \ )
endfunction

function! s:DefineLinks() abort
  let l:links = extend({
      \ 'EmptyField': 'Error',
      \ 'InvalidValue': 'Error',
      \ 'Url': 'Underlined',
      \ 'Todo': 'Todo',
      \ 'Enum': 'Type',
      \ 'Package': 'Type',
      \ 'Operator': 'Operator',
      \ 'Boolean': 'Boolean',
      \ 'Version': 'Number',
      \ 'Comment': 'Comment',
      \ 'Field': 'Define',
      \ 'Delimiter': 'Delimiter',
      \ 'Identifier': 'Identifier',
      \ 'Section': 'Statement',
      \ 'Keyword': 'Keyword',
      \ 'Conditional': 'Conditional',
      \ 'String': 'String',
      \ 'Underlined': 'Underlined',
      \ }, cabal#haddock#Links())
  call fn#dict#Map_(function('s:Link'), l:links)
endfunction

function! s:DefineField(field, value) abort
  let l:formatted_name = s:StripHyphens(a:field)
  let l:field_group = l:formatted_name . 'Field'
  let l:value_group = l:formatted_name . 'Value'
  let l:field_pattern = s:FieldPattern(a:field)
  let l:field_options = s:FieldOptions(a:value, l:value_group)
  call cabal#syntax#Match(l:field_group, l:field_pattern, l:field_options)
  let l:value_options = {'contained': 1}
  if has_key(a:value, 'contains')
    let l:value_options.contains = a:value.contains
  endif
  let l:value_pattern = s:ValuePattern(a:value)
  call cabal#syntax#Match(l:value_group, l:value_pattern, l:value_options)
  call s:Link(l:field_group, s:match_group_prefix . 'Field')
  if has_key(a:value, 'link')
    call s:Link(l:value_group, s:match_group_prefix . a:value.link)
  endif
endfunction

function! s:FieldOptions(value, value_group) abort
  let l:next_groups = [s:match_group_prefix . a:value_group]
  if !has_key(a:value, 'no-errors')
    let l:next_groups += [s:match_group_prefix . 'InvalidValue']
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

function! s:Link(from, to) abort
  call fn#Execute(
      \ 'highlight default link',
      \ s:match_group_prefix . a:from,
      \ a:to,
      \ )
endfunction

function! s:Pattern(string) abort
  return fn#Quote('\v' . a:string)
endfunction

function! s:StripHyphens(string) abort
  return substitute(a:string, '-', '', 'g')
endfunction

function! s:FormatOptions(options) abort
  return fn#dict#ConcatMap(function('s:FormatOption'), a:options)
endfunction

function! s:FormatOption(key, value) abort
  return a:key
      \ . (a:value is# 1 ? '' : '=' . s:FormatOptionValue(a:key, a:value))
      \ . ' '
endfunction

function! s:FormatOptionValue(key, value) abort
  return a:key is# 'matchgroup'     ? s:match_group_prefix . a:value
     \ : a:key is# 'skip'           ? s:Pattern(a:value)
     \ : type(a:value) is# type([]) ? join(a:value, ',')
     \ :                              a:value
endfunction

