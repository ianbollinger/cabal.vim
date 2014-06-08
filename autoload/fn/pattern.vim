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
function! fn#pattern#Match(string, pattern, default) abort
  let l:match = match(a:string, a:pattern)
  return s:ValidMatch(l:match) ? l:match : a:default
endfunction

""
"
function! fn#pattern#Choice(patterns) abort
  return s:Group(join(fn#assert#IsList(a:patterns), '|'))
endfunction

""
"
function! fn#pattern#SepBy1(pattern, separator) abort
  return a:pattern . fn#pattern#Many(a:separator . a:pattern)
endfunction

""
"
function! fn#pattern#Many(pattern) abort
  return s:Group(a:pattern) . '*'
endfunction

function! s:ValidMatch(match_result) abort
  return a:match_result >= 0
endfunction

function! s:Group(pattern) abort
  return '%(' . a:pattern . ')'
endfunction

