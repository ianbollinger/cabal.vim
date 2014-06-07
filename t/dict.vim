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

describe 'cabal#dict#Map_'
  it 'invokes function with key, value arguments'
    let g:results = []
    function! Flatten(key, value) abort
      call extend(g:results, [a:key, a:value])
    endfunction
    call cabal#dict#Map_(function('Flatten'), {'a': 'b', 'c': 'd'})
    Expect g:results == ['a', 'b', 'c', 'd']
  end
end

describe 'cabal#dict#FoldLeft'
  it 'returns initial on empty dictionary'
    Expect cabal#dict#FoldLeft(function('cabal#Id'), 'initial', {}) == 'initial'
  end
  it 'performs left fold over a dictionary'
    function! Combine(key, value, accumulator) abort
      return a:key . a:value . a:accumulator
    endfunction
    let g:Fn = function('Combine')
    Expect cabal#dict#FoldLeft(g:Fn, '', {'a': 'b', 'c': 'd'}) =~# 'abcd\|cdab'
  end
end

describe 'cabal#dict#ConcatMap'
  it 'returns does not invoke function when given an empty dictionary'
    let g:invoked = 0
    function! Invoked(key, value) abort
      let g:invoked = 1
    endfunction
    call cabal#dict#ConcatMap(function('Invoked'), {})
    Expect g:invoked == 0
  end
  it 'returns empty string when given an empty dictionary'
    Expect cabal#dict#ConcatMap(function('cabal#Id'), {}) == ''
  end
  it 'maps function over dict and concatenates results'
    function! Combine(key, value) abort
      return a:key . a:value
    endfunction
    let g:Fn = function('Combine')
    Expect cabal#dict#ConcatMap(g:Fn, {'a': 'b', 'c': 'd'}) =~# 'abcd\|cdab'
  end
end

describe 'cabal#dict#Union'
  it 'returns empty dictionary when given no arguments'
    Expect cabal#dict#Union() == {}
  end
  it 'returns identical dictionary when given one argument'
    Expect cabal#dict#Union({'a': 'b'}) == {'a': 'b'}
  end
  it 'is right-biased'
    Expect cabal#dict#Union({'a': 'b'}, {'a': 'c'}) == {'a': 'c'}
  end
  it 'returns the union of multiple dictionaries'
    Expect cabal#dict#Union({'a': 'b'}, {'c': 'd'}) == {'a': 'b', 'c': 'd'}
  end
end

