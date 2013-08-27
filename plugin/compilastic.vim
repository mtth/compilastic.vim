" Configuration

if !exists('g:compilastic_use_location_list')
  let g:compilastic_use_location_list = 1
endif

if !exists('g:compilastic_upper_limit')
  let g:compilastic_upper_limit = 5
endif

if !exists('g:compilastic_compile_on_write')
  let g:compilastic_compile_on_write = 0
endif

if !exists('g:compilastic_mappings')
  let g:compilastic_mappings = 1
endif

if !exists('g:compilastic_default_flags')
  let g:compilastic_default_flags = {}
endif

" Default compilation flags

if !has_key(g:compilastic_default_flags, 'haml')
  let g:compilastic_default_flags['haml'] = '% {%:t.html}'
endif
if !has_key(g:compilastic_default_flags, 'coffee -c')
  let g:compilastic_default_flags['coffee -c'] = '%'
endif
if !has_key(g:compilastic_default_flags, 'haml-coffee')
  let g:compilastic_default_flags['haml-coffee'] = '-i % -o {%:t.jst}'
endif
if !has_key(g:compilastic_default_flags, 'stylus')
  let g:compilastic_default_flags['stylus'] = '%'
endif

" Commands

command! -bang -nargs=* Compile call compilastic#compile(<q-args>, <bang>0)
command! -nargs=? Cinfo call compilastic#info(<q-args>)
command! -nargs=0 Cview call compilastic#view()

" Mappings

if g:compilastic_mappings
  nnoremap gc :Compile<cr>
  nnoremap gC :Cview<cr>
endif
