if exists('s:loaded') || &compatible
  finish
else
  let s:loaded = 1
endif


" State

let g:compiled_filepaths = {}

function! s:grow(elem) dict
  let data = self.data
  let position = match(data, '^' . a:elem . '$')
  if position >=# 0
    call add(data, remove(data, position))
  else
    call add(data, a:elem)
  endif
endfunction

function! s:latest() dict
  if len(self.data)
    return self.data[len(self.data) - 1]
  else
    return ''
  end
endfunction

function! s:full() dict
  return self.data
endfunction

function! s:make_stack()
  return {
  \ 'data': [],
  \ 'grow': function('s:grow'),
  \ 'latest': function('s:latest'),
  \ 'full': function('s:full')
  \ }
endfunction


" Utility

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
      let matches = matchlist(getline(line_number), 'c:\s\+\(.*\)$')
      if len(matches)
        return s:expand_all(matches[1])
      endif
    endif
  endfor
  if has_key(g:compilastic_default_flags, &l:makeprg)
    return s:expand_all(g:compilastic_default_flags[&l:makeprg])
  else
    return ''
  endif
endfunction

function! s:get_flags()
  " recover flags from compilastic modeline in current buffer
  " format is <comment string>c: <flags>
  " otherwise, return default flags if they exists
  " else, return empty string
  return substitute(s:get_modeline(), '{\([^{}]*\)}', '\=submatch(1)', '')
endfunction

function! s:get_filepath()
  " get filepath from flags
  " empty if not found
  let matches = matchlist(s:get_modeline(), '{\([^{}]*\)}')
  let path = len(matches) ? matches[1] : '.'
  if match(path, '[^/]\+\.[^/]\+$') >=# 0
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

function! compilastic#compile(flags, reset)
  " compile file
  echo 'Compiling...'
  if a:reset
    let flags = ''
  else
    let flags = s:get_flags()
  endif
  let flags = s:expand_all(a:flags) . ' ' . flags
  let output = system(&l:makeprg . ' ' . flags)
  redraw!
  if v:shell_error
    echoerr 'Compilation failed.' . output
  else
    echo 'Compilation successful!'
  endif
endfunction

function! compilastic#info(makeprg)
  " print information from compiler (defaults to current if non specified)
  if strlen(a:makeprg)
    let makeprg = a:makeprg
  else
    let makeprg = &l:makeprg
  endif
  if !strlen(makeprg)
    echoerr 'No compiler set.'
  elseif executable(split(makeprg)[0])
    echo system(makeprg . ' --help')
    if !strlen(a:makeprg)
      echo 'Current usage: ' . &l:makeprg . ' ' . s:get_flags()
    endif
  else
    echoerr 'Compiler not available: ' . makeprg
  endif
endfunction

function! compilastic#view()
  let filepath = s:get_filepath()
  if strlen(filepath) && filereadable(filepath)
    let autoread_save = &autoread
    let &autoread = 1
    execute 'edit ' . filepath
    let &autoread = autoread_save
  else
    echoerr 'Unable to find compiled file.'
  endif
endfunction
