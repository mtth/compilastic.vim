if exists('s:loaded') || &compatible
  finish
else
  let s:loaded = 1
endif

" Configuration

if !exists('g:compilastic_upper_limit')
  let g:compilastic_upper_limit = 5
endif

if !exists('g:compilastic_mappings')
  let g:compilastic_mappings = 1
endif

if !exists('g:compilastic_default_flags')
  let g:compilastic_default_flags = {}
endif

" Default compilation flags

if !has_key(g:compilastic_default_flags, 'haml')
  let g:compilastic_default_flags['haml'] = '% {%:r.html}'
endif
if !has_key(g:compilastic_default_flags, 'coffee')
  let g:compilastic_default_flags['coffee'] = '%'
endif
if !has_key(g:compilastic_default_flags, 'hamlc')
  let g:compilastic_default_flags['hamlc'] = '--input % --output {%:r.jst}'
endif
if !has_key(g:compilastic_default_flags, 'stylus')
  let g:compilastic_default_flags['stylus'] = '%'
endif
if !has_key(g:compilastic_default_flags, 'rst2html')
  let g:compilastic_default_flags['rst2html'] = '% {%:r.html}'
endif

" Commands

command! -bang -nargs=* Compile call compilastic#compile(<q-args>, <bang>0)
command! -nargs=0 Cinfo call compilastic#info()
command! -bang -nargs=0 Cview call compilastic#view(<bang>0)

" Mappings

if g:compilastic_mappings
  nnoremap gc :Compile<cr>
  nnoremap gC :Cview!<cr>
endif
