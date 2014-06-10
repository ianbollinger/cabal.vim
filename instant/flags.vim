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

let [s:bundle, s:enter] = fn#bundle#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

let s:root_fields = {
    \ 'author': {'pattern': 'free_form'},
    \ 'bug-reports': {'pattern': 'url', 'link': 'cabalUrl'},
    \ 'build-type': {'pattern': 'build_type', 'link': 'cabalEnum'},
    \ 'cabal-version': {
      \ 'pattern': 'cabal_version',
      \ 'contains': ['cabalOperator', 'cabalVersion'],
      \ },
    \ 'category': {'pattern': 'free_form'},
    \ 'copyright': {'pattern': 'free_form'},
    \ 'data-dir': {'pattern': 'token'},
    \ 'data-files': {'pattern': 'token_list'},
    \ 'description': {
      \ 'pattern': 'free_form',
      \ 'contains': ['@Spell', '@cabalHaddock']
      \ },
    \ 'extra-doc-files': {'pattern': 'token_list'},
    \ 'extra-source-files': {'pattern': 'token_list'},
    \ 'extra-tmp-files': {'pattern': 'token_list'},
    \ 'homepage': {'pattern': 'url', 'link': 'cabalUrl'},
    \ 'license': {'pattern': 'license', 'link': 'cabalEnum'},
    \ 'license-file': {'pattern': 'token'},
    \ 'maintainer': {'pattern': 'free_form'},
    \ 'name': {'pattern': 'package', 'link': 'cabalPackage'},
    \ 'package-url': {'pattern': 'url', 'link': 'cabalUrl'},
    \ 'stability': {'pattern': 'free_form', 'no-errors': 1},
    \ 'synopsis': {'pattern': 'free_form', 'contains': '@Spell'},
    \ 'tested-with': {
      \ 'pattern': 'compiler_list',
      \ 'contains': ['cabalOperator', 'cabalVersion'],
      \ },
    \ 'version': {'pattern': 'version', 'link': 'cabalVersion'},
    \ }

let s:library_fields = {
    \ 'exposed': {'pattern': 'boolean', 'link': 'cabalBoolean'},
    \ 'exposed-modules': {'pattern': 'identifier_list'},
    \ }

let s:build_info_fields = {
    \ 'build-depends': {
      \ 'pattern': 'package_list',
      \ 'contains': ['cabalOperator', 'cabalVersion'],
      \ },
    \ 'build-tools': {'pattern': 'program_list'},
    \ 'buildable': {'pattern': 'boolean', 'link': 'cabalBoolean'},
    \ 'c-sources': {'pattern': 'token'},
    \ 'cc-options': {'pattern': 'token_list'},
    \ 'default-language': {'pattern': 'language', 'link': 'cabalEnum'},
    \ 'extensions': {'pattern': 'extension_list'},
    \ 'extra-lib-dirs': {'pattern': 'token_list'},
    \ 'extra-libraries': {'pattern': 'token_list'},
    \ 'frameworks': {'pattern': 'token_list'},
    \ 'ghc-options': {'pattern': 'token_list'},
    \ 'ghc-prof-options': {'pattern': 'token_list'},
    \ 'ghc-shared-options': {'pattern': 'token_list'},
    \ 'hs-source-dir': {'pattern': 'token'},
    \ 'hs-source-dirs': {'pattern': 'token_list'},
    \ 'hugs-options': {'pattern': 'token_list'},
    \ 'include-dirs': {'pattern': 'token_list'},
    \ 'includes': {'pattern': 'token_list'},
    \ 'install-includes': {'pattern': 'token_list'},
    \ 'ld-options': {'pattern': 'token_list'},
    \ 'nhc98-options': {'pattern': 'token_list'},
    \ 'other-modules': {'pattern': 'identifier_list'},
    \ 'pkgconfig-depends': {'pattern': 'pkgconfig'},
    \ }

let s:executable_fields = {
    \ 'main-is': {'pattern': 'token'},
    \ }

let s:test_suite_fields = {
    \ 'test-module': {'pattern': 'identifier'},
    \ 'type': {'pattern': 'type', 'link': 'cabalEnum'},
    \ }

let s:flag_fields = {
    \ 'default': {'pattern': 'boolean', 'link': 'cabalBoolean'},
    \ 'manual': {'pattern': 'boolean', 'link': 'cabalBoolean'},
    \ }

let s:source_repository_fields = {
    \ 'branch': {'pattern': 'token'},
    \ 'location': {'pattern': 'url', 'link': 'cabalUrl'},
    \ 'module': {'pattern': 'token'},
    \ 'subdir': {'pattern': 'token'},
    \ 'tag': {'pattern': 'token'},
    \ }

let s:all_fields = fn#dict#Union(
    \ s:root_fields,
    \ s:library_fields,
    \ s:executable_fields,
    \ s:test_suite_fields,
    \ s:build_info_fields,
    \ s:flag_fields,
    \ s:source_repository_fields,
    \ )

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_fields', s:all_fields)

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_sections', [
    \ 'benchmark',
    \ 'executable',
    \ 'flag',
    \ 'library',
    \ 'source-repository',
    \ 'test-suite',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_build_types', [
    \ 'Configure',
    \ 'Custom',
    \ 'Make',
    \ 'Simple',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_licenses', [
    \ 'AGPL',
    \ 'AGPL-3',
    \ 'AllRightsReserved',
    \ 'Apache',
    \ 'Apache-2.0',
    \ 'BSD2',
    \ 'BSD3',
    \ 'GPL',
    \ 'GPL-2',
    \ 'GPL-3',
    \ 'LGPL',
    \ 'LGPL-2.1',
    \ 'LGPL-3',
    \ 'MIT',
    \ 'MPL-2.0',
    \ 'OtherLicense',
    \ 'PublicDomain',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_test_suite_types', [
    \ 'detailed-0.9',
    \ 'exitcode-stdio-1.0',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_test_benchmark_types', [
    \ 'exitcode-stdio-1.0',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_repository_kind', [
    \ 'head',
    \ 'this',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_repository_type', [
    \ 'arch',
    \ 'Bazaar',
    \ 'bzr',
    \ 'CVS',
    \ 'Darcs',
    \ 'Git',
    \ 'GnuArch',
    \ 'hg',
    \ 'Mercurial',
    \ 'Monotone',
    \ 'SVN',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_todo', [
    \ 'FIXME',
    \ 'TODO',
    \ 'XXX',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_compilers', [
    \ 'GHC',
    \ 'HBC',
    \ 'Helium',
    \ 'Hugs',
    \ 'JHC',
    \ 'LHC',
    \ 'NHC',
    \ 'UHC',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_operators', [
    \ '!',
    \ '\&\&',
    \ '\*',
    \ '\<',
    \ '\<\=',
    \ '\=\=',
    \ '\>',
    \ '\>\=',
    \ '\|\|',
    \ ])

call fn#bundle#SetFlagDefault(s:bundle, 'syntax_languages', [
    \ 'Haskell98',
    \ 'Haskell2010',
    \ ])

