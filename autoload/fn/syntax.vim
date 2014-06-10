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

function! fn#syntax#Highlighter(syntax, function)
  if !exists('b:current_syntax')
    call fn#WithDefaultCompatibilityOptions(a:function)
    let b:current_syntax = a:syntax
  endif
endfunction

""
" The name of the syntax match group under the cursor.
function! fn#syntax#NameAtCursor(...) abort
  let l:column = fn#cursor#Column() + (s:InInsertMode() ==# 'i' ? 0 : 1)
  return fn#syntax#Name(fn#cursor#TextLine(), l:column)
endfunction

""
" The name of the syntax match group at the given {line} and {column}.
function! fn#syntax#Name(line, column) abort
  return fn#syntax#Attribute('name', a:line, a:column)
endfunction

""
" The value of syntax {attribute} at the given {line} and {column}.
function! fn#syntax#Attribute(attribute, line, column) abort
  return synIDattr(synID(a:line, a:column, 0), a:attribute)
endfunction

""
"
function! fn#syntax#Link(from, to) abort
  call fn#Execute('highlight default link', a:from, a:to)
endfunction

""
"
function! fn#syntax#Keyword(group_name, keywords, ...) abort
  let l:options = a:0 > 0 ? a:1 : {}
  if !has_key(l:options, 'contained')
    let l:options.contained = 1
  endif
  call fn#Execute(
      \ 'syntax keyword',
      \ a:group_name,
      \ s:FormatOptions(l:options),
      \ join(a:keywords),
      \ )
endfunction

""
"
function! fn#syntax#Match(group_name, pattern, ...) abort
  let l:options = a:0 > 0 ? s:FormatOptions(a:1) : ' '
  call fn#Execute('syntax match', a:group_name, l:options, s:Pattern(a:pattern))
endfunction

""
"
function! fn#syntax#Region(group_name, start, end, ...) abort
  let l:options = a:0 > 0 ? s:FormatOptions(a:1) : ' '
  let l:start = 'start=' . s:Pattern(a:start)
  let l:end = 'end=' . s:Pattern(a:end)
  call fn#Execute('syntax region', a:group_name, l:start, l:end, l:options)
endfunction

function! s:InInsertMode() abort
  return mode() ==# 'i'
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
  return a:key is# 'skip'           ? s:Pattern(a:value)
     \ : type(a:value) is# type([]) ? join(a:value, ',')
     \ :                              a:value
endfunction

function! s:Pattern(string) abort
  return fn#Quote('\v' . a:string)
endfunction

