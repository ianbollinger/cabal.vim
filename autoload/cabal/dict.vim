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
" (Bi-)map {function} over a heterogeneous {dictionary} and discard the result.
function! cabal#dict#Map_(function, dictionary) abort
  call maktaba#ensure#IsFuncref(a:function)
  call maktaba#ensure#IsDict(a:dictionary)
  for [l:key, l:value] in items(a:dictionary)
    call a:function(l:key, l:value)
    unlet l:value
  endfor
endfunction

""
" Left fold {function} over a heterogeneous {dictionary}.
function! cabal#dict#FoldLeft(function, initial, dictionary) abort
  call maktaba#ensure#IsFuncref(a:function)
  call maktaba#ensure#IsDict(a:dictionary)
  let l:accumulator = a:initial
  for [l:key, l:value] in items(a:dictionary)
    let l:accumulator = a:function(l:key, l:value, l:accumulator)
    unlet l:value
  endfor
  return l:accumulator
endfunction

""
" Map {function} over a heterogeneous {dictionary} and concatenate the result.
function! cabal#dict#ConcatMap(function, dictionary) abort
  call maktaba#ensure#IsFuncref(a:function)
  call maktaba#ensure#IsDict(a:dictionary)
  let l:accumulator = ''
  for [l:key, l:value] in items(a:dictionary)
    let l:accumulator .= a:function(l:key, l:value)
    unlet l:value
  endfor
  return l:accumulator
endfunction

""
" Right-biased union of a sequence of dictionaries.
function! cabal#dict#Union(...) abort
  let l:accumulator = {}
  for l:dictionary in a:000
    call maktaba#ensure#IsDict(l:dictionary)
    call extend(l:accumulator, l:dictionary)
  endfor
  return l:accumulator
endfunction

