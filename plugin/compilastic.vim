if !exists('g:compilastic_use_location_list')
  let g:compilastic_use_location_list = 1
endif

if !exists('g:compilastic_compile_on_write')
  let g:compilastic_compile_on_write = 0
endif

if !exists('g:compilastic_mappings')
  let g:compilastic_mappings = 1
endif

command! -bang -nargs=* Compile call compilastic#compile(<q-args>, <bang>0)
command! -nargs=? Cinfo call compilastic#info(<q-args>)
command! -nargs=* -range Cstream call compilastic#stream(<q-args>)
command! -nargs=0 Cview call compilastic#view()

if g:compilastic_mappings
  nnoremap gc :Compile<cr>
  nnoremap gC :Compile!<cr>
  xnoremap gc :Cstream<cr>
  xnoremap gC :Cstream!<cr>
endif
