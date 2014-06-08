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

""
"
function! cabal#indent#Main() abort
  setlocal autoindent
  setlocal nolisp
  setlocal indentexpr=cabal#indent#IndentExpr(v:lnum)
  call s:SetIndentKeys(['!^F', 'o', 'O'])
  let b:did_indent = 1
endfunction

""
"
function! cabal#indent#IndentExpr(line_number) abort
  let l:previous_line = getline(a:line_number - 1)
  return
      \ s:IsAllWhitespace(l:previous_line)   ? 0            :
      \ s:IsLongField(l:previous_line)       ? shiftwidth() :
      \ s:IsIncompleteField(l:previous_line) ? s:IncompleteFieldIndent(a:line_number) :
      \                                        indent(a:line_number - 1)
endfunction

function! s:SetIndentKeys(keys) abort
  call cabal#Execute('setlocal', 'indentkeys=' . join(a:keys, ','))
endfunction

function! s:IndentOfPreviousField(line_number) abort
  for l:line_number in range(a:line_number, 0, -1)
    let l:line = getline(l:line_number)
    if s:IsField(l:line)
      return indent(l:line_number)
    endif
  endfor
  return 0
endfunction

function! s:IndentOfNextField(line_number) abort
  for l:line_number in range(a:line_number, line('$'))
    let l:line = getline(l:line_number)
    if s:IsField(l:line)
      return indent(l:line_number)
    endif
  endfor
  return 0
endfunction

function! s:LongFieldNames() abort
  return ['build-depends', 'description', 'exposed-modules']
endfunction

function! s:IsAllWhitespace(string) abort
  return a:string =~# '\v^\s*$'
endfunction

function! s:IsLongField(string) abort
  let l:pattern =
      \ '\v^\s*' . cabal#pattern#Choice(s:LongFieldNames()) . '\s*:\s*'
  return a:string =~# l:pattern
endfunction

function! s:IsIncompleteField(string) abort
  return a:string =~# '\v^\s*[[:alpha:]-]+\s*:\s*$'
endfunction

function! s:IncompleteFieldIndent(lnum) abort
  let l:next_line = getline(a:lnum + 1)
  if s:IsField(l:next_line) || s:IsAllWhitespace(l:next_line)
    return shiftwidth()
  else
    return indent(a:lnum + 1)
  endif
endfunction

function! s:IsField(string) abort
  return a:string =~# '\v^\s*[[:alpha:]-]+\s*:\s*'
endfunction

