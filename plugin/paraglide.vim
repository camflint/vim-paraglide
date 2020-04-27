" paraglide.vim - Provides paragraph beginning and ending markers
" Maintainer: Cameron Flint <dev@caflint.fastmail.com>
" Version: 1.0
" License: MIT

if exists('g:loaded_paraglide') || &cp
  finish
endif
let g:loaded_paraglide = 0

" Section: Functions

function! s:get_top_bottom_edge()
  const line = line('.')
  const regex = '\v^$'
  const at_top = (line == 1) || (getline(line - 1) =~ regex)
  const at_bottom = (line == line('$')) || (getline(line + 1) =~ regex)
  return [at_top, at_bottom]
endfunction

" direction=down|up, edge=start|end|any
function! s:jump_paragraph_edge(direction, edge)
  const down = a:direction ==# 'down'
  const up = !down
  const start = a:edge ==# 'start'
  const end = a:edge ==# 'end'
  const any = !start && !end

  const dirsign = down ? 1 : -1
  const flags = 'W' . (down ? '' : 'b')
  const re_empty_line = '\v^$'
  const re_nonempty_line = '\v^.+$'

  " Jump out of the current paragraph if we need to.
  let jump_out = v:false
  if getline('.') =~ re_nonempty_line
    let [at_top_edge, at_bottom_edge] = s:get_top_bottom_edge()
    if (down && at_bottom_edge) || (up && at_top_edge)
      let jump_out = v:true
    elseif !any && ((down && !end) || (up && !start))
      let jump_out = v:true
    endif
  endif
  if jump_out
    if !search(re_empty_line, flags) | return | endif
  endif

  " Make sure we land in a paragraph.
  if getline('.') =~ re_empty_line
    if !search(re_nonempty_line, flags) | return | endif
  endif

  " Snap to the edge if not already.
  let jump_again = v:false
  let [at_top_edge, at_bottom_edge] = s:get_top_bottom_edge()
  if (start && !at_top_edge) || (end && !at_bottom_edge)
    let jump_again = v:true
  elseif any && (!at_top_edge && !at_bottom_edge)
    let jump_again = v:true
  elseif any && !jump_out
    let jump_again = v:true
  endif
  if jump_again
    const re_boundary = re_empty_line . (down ? '|%$' : '|%^')
    if search(re_boundary, flags) && getline('.') =~ re_empty_line
      call cursor(line('.') - dirsign, 1)
    endif
  endif
endfunction

" Section: Maps

nnoremap <script> <Plug>ParaglideDownStart :<C-U>call <SID>jump_paragraph_edge('down', 'start')<CR>
onoremap <script> <Plug>ParaglideDownStart :<C-U>call <SID>jump_paragraph_edge('down', 'start')<CR>
nnoremap <script> <Plug>ParaglideDownEnd   :<C-U>call <SID>jump_paragraph_edge('down', 'end')<CR>
onoremap <script> <Plug>ParaglideDownEnd   :<C-U>call <SID>jump_paragraph_edge('down', 'end')<CR>
nnoremap <script> <Plug>ParaglideUpStart   :<C-U>call <SID>jump_paragraph_edge('up', 'start')<CR>
onoremap <script> <Plug>ParaglideUpStart   :<C-U>call <SID>jump_paragraph_edge('up', 'start')<CR>
nnoremap <script> <Plug>ParaglideUpEnd     :<C-U>call <SID>jump_paragraph_edge('up', 'end')<CR>
onoremap <script> <Plug>ParaglideUpEnd     :<C-U>call <SID>jump_paragraph_edge('up', 'end')<CR>
nnoremap <script> <Plug>ParaglideDownAny   :<C-U>call <SID>jump_paragraph_edge('down', 'any')<CR>
onoremap <script> <Plug>ParaglideDownAny   :<C-U>call <SID>jump_paragraph_edge('down', 'any')<CR>
nnoremap <script> <Plug>ParaglideUpAny     :<C-U>call <SID>jump_paragraph_edge('up', 'any')<CR>
onoremap <script> <Plug>ParaglideUpAny     :<C-U>call <SID>jump_paragraph_edge('up', 'any')<CR>

function! s:default_maps()
  nmap <silent> <down>  <Plug>ParaglideDownStart
  omap <silent> <down>  <Plug>ParaglideDownStart
  nmap <silent> }       <Plug>ParaglideDownEnd
  omap <silent> }       <Plug>ParaglideDownEnd
  nmap <silent> <up>    <Plug>ParaglideUpStart
  omap <silent> <up>    <Plug>ParaglideUpStart
  nmap <silent> {       <Plug>ParaglideUpEnd
  omap <silent> {       <Plug>ParaglideUpEnd
  nmap <silent><nowait> g<down> <Plug>ParaglideDownAny
  omap <silent><nowait> g<down> <Plug>ParaglideDownAny
  nmap <silent><nowait> g<up>   <Plug>ParaglideUpAny
  omap <silent><nowait> g<up>   <Plug>ParaglideUpAny
endfunction

if get(g:, 'paraglide_default_maps', 1) == 1
  call s:default_maps()
endif

" vim:set sw=2 sts=2:
