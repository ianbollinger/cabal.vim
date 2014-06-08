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
" See @function(cabal#Omnifunc).
function! cabal#completion#Omnifunc(find_start, current_completion) abort
  return a:find_start
      \ ? s:FindCompletionStart()
      \ : s:DoCompletion(a:current_completion)
endfunction

function! s:FindCompletionStart() abort
  return s:CompletionPossible() ? s:CompletionPosition() : s:CompletionError()
endfunction

function! s:CompletionPossible() abort
  return fn#cursor#Column() > 0
endfunction

function! s:CompletionPosition() abort
  return s:InsideComment() ? s:CompletionError() : s:KeywordPosition()
endfunction

function! s:CompletionError() abort
  return -1
endfunction

function! s:InsideComment() abort
  return fn#syntax#NameAtCursor() =~# 'Comment'
endfunction

function! s:KeywordPosition() abort
  return s:PatternPosition(s:KeywordPattern(), s:LineBeforeCursor())
endfunction

function! s:DoCompletion(current_completion) abort
  return s:CompleteWords(s:CompletionPosition(), a:current_completion)
endfunction

function! s:LineBeforeCursor() abort
  return s:LineBeforeColumn(fn#cursor#Column())
endfunction

function! s:LineBeforeColumn(column) abort
  return fn#cursor#LineText()[: a:column - 1]
endfunction

function! s:CompleteWords(completion_position, current_completion) abort
  let [l:text, l:truncate] =
      \ s:InvokedFromYouCompleteMe(a:completion_position, a:current_completion)
      \ ? [s:LineBeforeCursor()[a:completion_position :], 1]
      \ : [a:current_completion, 0]
  return {'words': s:FilteredFieldNames(text, truncate)}
endfunction

function! s:FilteredFieldNames(completion, truncate) abort
  let l:x = filter(
      \ cabal#syntax#Keywords(),
      \ 'maktaba#string#StartsWith(v:val, a:completion)')
  return a:truncate ? map(l:x, 'strpart(v:val, l:length)') : l:x
endfunction

function! s:InvokedFromYouCompleteMe(position, completion) abort
  return a:position != fn#cursor#Column() && empty(a:completion)
endfunction

function! s:PatternPosition(pattern, string) abort
  return fn#pattern#Match(a:string, a:pattern, strlen(a:string))
endfunction

function! s:KeywordPattern() abort
  return '\v[[:alpha:]-][[:alnum:]-]*$'
endfunction

