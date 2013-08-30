if exists('s:loaded') || &compatible
  finish
else
  let s:loaded = 1
endif

" Utility

function! s:get_compiler()
  " local compiler if set else global
  if exists('b:current_compiler')
    return b:current_compiler
  elseif exists('current_compiler')
    return current_compiler
  else
    return ''
  endif
endfunction

function! s:get_makeprg()
  " local or global makeprg
  if strlen(&l:makeprg)
    return &l:makeprg
  else
    return &makeprg
  endif
endfunction

function! s:expand_all(input_string)
  " Perform command line expansion on string (i.e. % to filepath, etc.)
  " literal % can be added by escaping them: \%
  let input_string = substitute(
  \ a:input_string,
  \ '\(^\|[^\\]\)\zs%\(<\|:[phtre]\)*',
  \ '\=expand(submatch(0))',
  \ 'g'
  \ )
  return substitute(input_string, '\\%', '%', 'g')
endfunction

" Flags

function! s:get_modeline()
  " also performs command-line expansion
  let last_line = line('$')
  for line_number in range(last_line, last_line - g:compilastic_upper_limit, -1)
    if synIDattr(synIDtrans(synID(line('$'), col('.'), 0)), 'name') == 'Comment'
      let matches = matchlist(getline(line_number), 'make:\s\+\(.*\)$')
      if len(matches)
        return s:expand_all(matches[1])
      endif
    endif
  endfor
  if has_key(g:compilastic_default_flags, s:get_compiler())
    return s:expand_all(g:compilastic_default_flags[s:get_compiler()])
  else
    return ''
  endif
endfunction

function! s:get_flags()
  " recover flags from compilastic modeline in current buffer
  " format is <comment string>make: <flags>
  " otherwise, return default flags if they exists
  " else, return empty string
  return substitute(s:get_modeline(), '&', '', 'g')
endfunction

function! s:get_filepath()
  " get filepath from flags
  " empty if not found
  let matches = matchlist(s:get_modeline(), '&\(\S\+\)')
  let path = len(matches) ? matches[1] : '.'
  if filereadable(path)
    return path
  else
    let filepaths = split(globpath(path, expand('%:t:r') . '.*'), '\n')
    let filepaths = filter(filepaths, 'v:val !~# ".' . expand('%:e') . '$"')
    if len(filepaths) ==# 1
      return filepaths[0]
    elseif len(filepaths)
      let position = 0
      let available_filepaths = []
      for filepath in filepaths
        let position += 1
        call add(available_filepaths, position . '. ' . filepath)
      endfor
      let chosen_filepath = inputlist(extend(['Multiple files found'], available_filepaths)) - 1
      if chosen_filepath >=# 0
        return filepaths[chosen_filepath]
      endif
    else
      return ''
  endif
endfunction

" Public functions

function! compilastic#compile(flags, load_errors)
  " compile file
  echo 'Compiling...'
  let flags = s:expand_all(a:flags) . ' ' . s:get_flags()
  let output = system(s:get_makeprg() . ' ' . flags)
  redraw!
  let status = v:shell_error
  if status
    if a:load_errors
      lexpr output
    else
      echoerr 'Compilation failed.' . output
    endif
  else
    echo 'Compilation successful!'
  endif
  return status
endfunction

function! compilastic#info()
  " print information from compiler
  let makeprg = s:get_makeprg()
  if !strlen(makeprg)
    echoerr 'No compiler set.'
  elseif executable(split(makeprg)[0])
    echo 'Current usage: ' . makeprg . ' ' . s:get_flags() . "\n\n"
    echo system(makeprg . ' --help')
  else
    echoerr 'Compiler not available: ' . makeprg
  endif
endfunction

function! compilastic#run(arguments, refresh)
  " run compiled file
  if a:refresh
    let status = compilastic#compile('', 0)
    if status
      return
    else
      redraw!
    endif
  endif
  let filepath = s:get_filepath()
  if strlen(filepath)
    if executable(filepath)
      echo system(filepath . ' ' . a:arguments)
      if v:shell_error
        echoerr 'Non-zero return value for ' . filepath . ': ' . v:shell_error
      endif
    else
      echoerr 'Compiled file ' . filepath . ' is not executable.'
    endif
  else
    echoerr 'Unable to find compiled executable at ' . filepath
  endif
endfunction

function! compilastic#view(prog, refresh)
  " view compiled file
  if a:refresh
    let status = compilastic#compile('', 0)
    if status
      return
    endif
  endif
  let filepath = s:get_filepath()
  if strlen(filepath)
    if strlen(a:prog)
      execute '!' . a:prog . ' ' . filepath
    else
      let autoread_save = &autoread
      let &autoread = 1
      execute 'edit ' . filepath
      let &autoread = autoread_save
    endif
  else
    echoerr 'Unable to find compiled file at ' . filepath
  endif
endfunction

function! compilastic#run_or_view()
  " refresh then run if executable else open in vim
  if compilastic#compile('', 0)
    return
  endif
  let filepath = s:get_filepath()
  if strlen(filepath)
    if executable(filepath)
      call compilastic#run('', 0)
    else
      call compilastic#view('', 0)
    endif
  else
    echoerr 'Unable to find compiled file at ' . filepath
  endif
endfunction
