" utils"{{{
function! s:current_git() "{{{
  let current_dir = getcwd()
  if !exists("s:git_root_cache") | let s:git_root_cache = {} | endif
  if has_key(s:git_root_cache, current_dir)
    return s:git_root_cache[current_dir]
  endif

  let git_root = system("git rev-parse --show-toplevel")
  if git_root =~ "fatal: Not a git repository"
    " throw "No a git repository."
    return ""
  endif

  let s:git_root_cache[current_dir] = substitute(git_root, '\n', '', 'g')

  return s:git_root_cache[current_dir]
endfunction "}}}

function! s:get_root_dir() "{{{
  if exists('b:rspec_parent_dir')
    return b:rspec_parent_dir
  elseif exists('b:rails_root')
    return b:rails_root . '/'
  elseif !empty(s:current_git())
    return s:current_git() . '/'
  else
    return 0
  endif
endfunction "}}}

function! s:get_relative_path(path) " {{{
  if !empty(s:get_root_dir())
    return substitute(a:path, '^' . s:get_root_dir(), '', 'g')
  else
    return @%
  endif
endfunction "}}}

function! s:in_spec_file() "{{{
  let file_path = expand("%")
  return file_path =~ '\v(_spec\.rb|\.feature)$'
endfunction "}}}
"}}}

function! neorspec#run_spec_or_retry() "{{{
  try
    let alternate = rails#buffer().alternate()

    let is_specfile = alternate =~ '_spec\.rb$'
    let is_readable = filereadable(b:rails_root . '/' . alternate)

    if is_specfile && is_readable
      call neorspec#run_specs(alternate)
    else
      echomsg alternate . " can't find"
      throw 'Error occurd'
    endif
  catch /.*/
    call neorspec#retry()
  endtry
endfunction "}}}

function! neorspec#run_all() "{{{
  call neorspec#run_specs('spec')
endfunction "}}}

function! neorspec#run(path) "{{{
  let args = a:path
  if empty(args)
    return neorspec#run_all()
  elseif args =~ '^\.$'
    return neorspec#current_spec_file()
  else
    let current_dir = getcwd()
    let relative_path_list = map(split(args, '\s\+'), '<SID>get_relative_path(current_dir . "/" . v:val)')
    let spec = join(relative_path_list, ' ') 

    return neorspec#run_specs(spec)
  endif
endfunction "}}}

function! neorspec#current_spec_file() "{{{
  if s:in_spec_file()
    call neorspec#run_specs(s:get_relative_path(expand("%:p")))
  else
    call neorspec#run_spec_or_retry()
  endif
endfunction "}}}

function! neorspec#nearest_spec() "{{{
  if s:in_spec_file()
    call neorspec#run_specs(s:get_relative_path(expand("%:p")) . ":" . line("."))
  else
    call neorspec#run_spec_or_retry()
  endif
endfunction "}}}

function! neorspec#retry() "{{{
  if exists('s:last_spec_command')
    call neorspec#run_specs(s:last_spec_command)
  else
    echomsg 'No rspec command is executed'
  endif
endfunction "}}}

function! neorspec#run_specs(spec) "{{{
  let s:last_spec_command = a:spec

  if g:neorspec_debug | echomsg 'spec... ' . a:spec | endif

  if !empty(s:get_root_dir())
    let g:root = s:get_root_dir()
    let current_path = expand("%:p:h")
    lcd `=s:get_root_dir()`
  endif

  execute substitute(g:neorspec_command, "{spec}", a:spec, "g")

  if !empty(s:get_root_dir())
    lcd `=current_path`
  endif
endfunction "}}}

