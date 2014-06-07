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

describe 'cabal#Omnifunc'
end

describe 'cabal#WithDefaultCompatibilityOptions'
end

describe 'cabal#Execute'
  it 'calls execute with concatenated arguments'
    let g:example = ''
    call cabal#Execute('let g:example', '=', '"foo', 'bar"')
    Expect g:example is# 'foo bar'
  end
end

describe 'cabal#Quote'
  it 'surrounds strings with quotation marks'
    Expect cabal#Quote('a string') is# '"a string"'
  end
  it 'escapes quotation marks'
    Expect cabal#Quote('"quotes"') is# '"\"quotes\""'
  end
end

describe 'cabal#CursorColumn'
  it 'returns the column of the character left of the cursor'
    " TODO: this just copies the implementation.
    Expect cabal#CursorColumn() == col('.') - 1
  end
end

describe 'cabal#CursorLine'
  it 'returns the line the cursor is on'
  end
end

describe 'cabal#ListFind'
  it 'returns the first item that matches predicate'
    let l:list = ['one', 'two', 'three', 'four', 'five']
    function! LengthFour(string) abort
      return strlen(a:string) == 4
    endfunction
    Expect cabal#ListFind(function('LengthFour'), '', l:list) is# 'four'
  end
end

describe 'cabal#Id'
  it 'is the identity function'
    Expect cabal#Id('x') is# 'x'
  end
end

