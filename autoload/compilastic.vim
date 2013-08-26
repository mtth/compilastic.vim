if exists('s:loaded') || &compatible
  finish
else
  let s:loaded = 1
endif

function! compilastic#compile(flags, load_errors)
  " look in last line of file for compiling options
  echo 'Compiling...'
  if synIDattr(synIDtrans(synID(line('$'), col('.'), 0)), 'name') == 'Comment'
    let compile_options = g:expand_all(join(split(getline('$'))[1:]))
  else
    if exists('b:compilastic_default_options')
      let compile_options = b:get_default_compilation_options()
    else
      let compile_options = ''
    endif
  endif
  let output = system(&l:makeprg . ' ' . compile_options)
  redraw!
  if v:shell_error
    echoerr 'Compilation failed.'
    if a:load_errors
      l
    endif
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
  echo system(makeprg . ' --help')
endfunction

function! compilastic#stream(flags)
  " stream selection to compiler and output result
  return
endfunction

function! compilastic#view()
  if exists('b:compilastic_filepath')
    let filepath = b:get_compiled_filepath()
    if filereadable(filepath)
      let autoread_save = &autoread
      let &autoread = 1
      execute 'edit ' . filepath
      let &autoread = autoread_save
    else
      echoerr 'No compiled file found at ' . filepath
    endif
  else
    echoerr 'Unable to find compiled filepath.'
  endif
endfunction
