"=============================================================================
" FILE: rspec.vim
" AUTHOR: Ishii Hiroyuki <alprhcp666@gmail.com>
" Last Modified: 2013-07-06
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

if exists('g:loaded_rspec')
  finish
endif
let g:loaded_rspec = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:rspec_command') "{{{
  let s:cmd = 'rspec {spec}'

  if exists(':Dispatch')
    let g:rspec_command = 'Dispatch ' . s:cmd
  else
    let g:rspec_command = '!echo ' . s:cmd . ' && ' . s:cmd
  endif
endif "}}}

command! -nargs=0 RSpecAll call rspec#run_all()
command! -nargs=0 RSpecNearest call rspec#nearest_spec() 
command! -nargs=0 RSpecRetry call rspec#retry()
command! -nargs=0 RSpecCurrent call rspec#current_spec_file()
command! -nargs=* -complete=file RSpec call rspec#run(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
