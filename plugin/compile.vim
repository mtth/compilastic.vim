if exists('s:loaded') || &compatible
  finish
else
  let s:loaded = 1
endif

" Configuration

if !exists('g:compile_upper_limit')
  let g:compile_upper_limit = 5
endif
if !exists('g:compile_mappings')
  let g:compile_mappings = 1
endif
if !exists('g:compile_default_flags')
  let g:compile_default_flags = {}
endif
if !exists('g:compile_transient_view')
  let g:compile_transient_view = 1
endif

" Commands

command! -bang -nargs=* Compile call compile#compile(<q-args>, <bang>0)
command! -nargs=0 Cinfo call compile#info()
command! -bang -nargs=* Crun call compile#run(<q-args>, <bang>0)
command! -bang -nargs=* Cview call compile#view(<q-args>, <bang>0)

" Mappings

if g:compile_mappings
  nnoremap gc :Compile<cr>
  nnoremap gC :call compile#run_or_view()<cr>
endif
