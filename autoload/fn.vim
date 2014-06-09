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
function! fn#WithDefaultCompatibilityOptions(func)
  let l:saved_compatibility_options = s:GetAndResetCompatibilityOptions()
  try
    call a:func()
  finally
    call s:RestoreCompatibilityOptions(l:saved_compatibility_options)
  endtry
endfunction

""
"
function! fn#Execute(...) abort
  execute join(a:000)
endfunction

""
" Surround a {string} with double quotes and escape any double quotes marks it
" contains.
function! fn#Quote(string) abort
  return '"' . escape(a:string, '"') . '"'
endfunction

""
" The identity function.
function! fn#Id(x) abort
  return a:x
endfunction

function! s:GetAndResetCompatibilityOptions() abort
  let l:saved_compatibility_options = &cpoptions
  set cpoptions&vim
  return l:saved_compatibility_options
endfunction

function! s:RestoreCompatibilityOptions(saved_compatibility_options) abort
  let &cpoptions = a:saved_compatibility_options
endfunction

