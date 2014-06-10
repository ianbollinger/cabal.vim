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
function! cabal#haddock#Main() abort
  "call fn#syntax#Region('cabalHaddockSnippet', '[^\\]\zs\>%(\>\>)=', '$', {
  "    \ 'matchgroup': 'cabalDelimiter',
  "    \ 'contains': '@Haskell',
  "    \ 'contained': 1,
  "    \ 'containedin': '@cabalHaddock',
  "    \ 'oneline': 1,
  "    \ })
  " \ 'matchgroup': 'cabalDelimiter',
  call fn#syntax#Region('cabalHaddockUrl', '[^\\]\zs\<', '[^\\]\zs\>', {
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ 'oneline': 1,
      \ 'keepend': 1,
      \ })
  call fn#syntax#Region('cabalHaddockImage', '[^\\]\zs\<\<', '[^\\]\zs\>\>', {
      \ 'matchgroup': 'cabalHaddockDelimiter',
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ 'oneline': 1,
      \ 'keepend': 1,
      \ })
  call fn#syntax#Region('cabalHaddockSymbol', '\s' . "'", '[^\\]\zs' . "'", {
      \ 'matchgroup': 'cabalHaddockDelimiter',
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ 'oneline': 1,
      \ })
  call fn#syntax#Region('cabalHaddockModule', '[^\\]\zs"', '[^\\]\zs"', {
      \ 'matchgroup': 'cabalHaddockDelimiter',
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ 'oneline': 1,
      \ 'keepend': 1,
      \ })
  call fn#syntax#Region('cabalHaddockSnippet', '[^\\]\zs\@', '[^\\]\zs\@', {
      \ 'matchgroup': 'cabalHaddockDelimiter',
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ 'contains': '@Haskell',
      \ })
  call fn#syntax#Region('cabalHaddockItalics', '[^\\]\zs/', '[^\\]\zs/', {
      \ 'matchgroup': 'cabalHaddockDelimiter',
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ 'oneline': 1,
      \ 'keepend': 1
      \ })
  call fn#syntax#Region('cabalHaddockBold', '[^\\]\zs__', '[^\\]\zs__', {
      \ 'matchgroup': 'cabalHaddockDelimiter',
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ 'oneline': 1,
      \ 'keepend': 1
      \ })
  call fn#syntax#Match('cabalHaddockList', '^\s+%(\*|\d+\.|\(\d+\))', {
      \ 'display': 1,
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
     \ })
  call fn#syntax#Match('cabalHaddockHeading', '^\s+\=+.*', {
      \ 'display': 1,
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ })
  call fn#syntax#Match('cabalHaddockEscape', '\\.', {
      \ 'display': 1,
      \ 'contained': 1,
      \ 'containedin': '@cabalHaddock',
      \ })
   call s:DefineCluster()
endfunction

function! s:DefineCluster() abort
  syntax cluster cabalHaddock contains=
      \ cabalHaddockBold,
      \ cabalHaddockDelimiter,
      \ cabalHaddockEscape,
      \ cabalHaddockHeading,
      \ cabalHaddockImage,
      \ cabalHaddockItalics,
      \ cabalHaddockList,
      \ cabalHaddockModule,
      \ cabalHaddockSnippet,
      \ cabalHaddockSymbol,
      \ cabalHaddockUrl
endfunction

""
"
function! cabal#haddock#Links() abort
  return {
      \ 'cabalHaddockBold': 'String',
      \ 'cabalHaddockDelimiter': 'Delimiter',
      \ 'cabalHaddockEscape': 'SpecialCharacter',
      \ 'cabalHaddockHeading': 'String',
      \ 'cabalHaddockImage': 'cabalUrl',
      \ 'cabalHaddockItalics': 'String',
      \ 'cabalHaddockList': 'Delimiter',
      \ 'cabalHaddockModule': 'String',
      \ 'cabalHaddockSymbol': 'String',
      \ 'cabalHaddockUrl': 'cabalUrl'
      \ }
endfunction

