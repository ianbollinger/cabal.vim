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

function! s:InInsertMode() abort
  return mode() ==# 'i'
endfunction

