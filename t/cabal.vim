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

describe 'fn#WithDefaultCompatibilityOptions'
end

describe 'fn#Execute'
  it 'calls execute with concatenated arguments'
    let g:example = ''
    call fn#Execute('let g:example', '=', '"foo', 'bar"')
    Expect g:example is# 'foo bar'
  end
end

describe 'fn#Quote'
  it 'surrounds strings with quotation marks'
    Expect fn#Quote('a string') is# '"a string"'
  end
  it 'escapes quotation marks'
    Expect fn#Quote('"quotes"') is# '"\"quotes\""'
  end
end

describe 'fn#cursor#Column'
  it 'returns the column of the character left of the cursor'
    " TODO: this just copies the implementation.
    Expect fn#cursor#Column() == col('.') - 1
  end
end

describe 'fn#cursor#LineText'
  it 'returns the text of the line the cursor is on'
  end
end

describe 'fn#list#Find'
  it 'returns the first item that matches predicate'
    let l:list = ['one', 'two', 'three', 'four', 'five']
    function! LengthFour(string) abort
      return strlen(a:string) == 4
    endfunction
    Expect fn#list#Find(function('LengthFour'), '', l:list) is# 'four'
  end
end

describe 'fn#Id'
  it 'is the identity function'
    Expect fn#Id('x') is# 'x'
  end
end

