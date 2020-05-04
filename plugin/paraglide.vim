" paraglide.vim - Provides paragraph beginning and ending markers
" Maintainer: Cameron Flint <dev@caflint.fastmail.com>
" Version: 1.0
" License: MIT

" Section: Globals.

if get(g:, 'loaded_paraglide', 0) || &cp
  finish
endif
let g:loaded_paraglide = 1

" Section: Settings.

let s:default_maps    = get(g:, 'paraglide_default_maps', 1)
let s:modify_jumplist = get(g:, 'paraglide_modify_jumplist', 1)
let s:wrap            = get(g:, 'paraglide_wrap', 0)

" Section: Regular expressions.

const s:re_empty_line             = '\v^\s*$'
const s:re_empty_line_from_col    = '\v^.{,{count}}\s*$'
const s:re_nonempty_line          = '\v^\s*[^[:space:]]+.*$'
const s:re_nonempty_line_from_col = '\v^.{{count}}\s*[^[:space:]]+.*$'

" Section: Functions.

function! s:get_top_bottom_edge(re_empty_line)
  const line = line('.')
  const at_top = (line == 1) || (getline(line - 1) =~ a:re_empty_line)
  const at_bottom = (line == line('$')) || (getline(line + 1) =~ a:re_empty_line)
  return [at_top, at_bottom]
endfunction

" direction=down|up, edge=start|end|block|any
function! s:jump_paragraph_edge(direction, edge, mode)
  const down = a:direction ==# 'down'
  const up = !down
  const start = a:edge ==# 'start'
  const end = a:edge ==# 'end'
  const block = a:edge ==# 'block'
  const any = (!start && !end) || block

  const dirsign = down ? 1 : -1
  const flags = 'z' . (!s:wrap ? 'W' : '') . (down ? '' : 'b')
  const saved_pos = getcurpos()
  const viz = tolower(a:mode) =~ '\v^[vs]$'
  const vblock = a:mode ==# ''

  " Use different regular expressions for normal vs. block (column) edge mode.
  const re_empty_line =
        \ !block ? 
        \ s:re_empty_line :
        \ substitute(s:re_empty_line_from_col, '\v\{count\}', max([0, saved_pos[2]-1]), '')
  const re_nonempty_line = 
        \ !block ? 
        \ s:re_nonempty_line :
        \ substitute(s:re_nonempty_line_from_col, '\v\{count\}', max([0, saved_pos[2]-1]), '')

  " Update jumplist, if applicable.
  if s:modify_jumplist
    " Calling search(), cursor(), or setpos() don't normally update the
    " jumplist. However by setting the ' mark, we can do so manually.
    normal! m'
  endif

  " Restore visual selection, if applicable.
  if viz
    normal gv
  endif

  " Jump out of the current paragraph, if needed.
  let jump_out = v:false
  if getline('.') =~ re_nonempty_line
    let [at_top_edge, at_bottom_edge] = s:get_top_bottom_edge(re_empty_line)
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
  let [at_top_edge, at_bottom_edge] = s:get_top_bottom_edge(re_empty_line)
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

  " Restore column, off, and curswant.
  " This is necessary because we had to change the cursor position for search()s.
  let pos = saved_pos
  let pos[1] = getpos('.')[1] " At the end, we'll have only moved the line number.
  call setpos('.', pos)
endfunction

" Section: Maps

for mode_ in ['n', 'v', 'o']
  for direction in ['down', 'up']
    for edge in ['start', 'end', 'any', 'block']
      let s:lhs = '<Plug>Paraglide'.toupper(direction[0]).direction[1:].toupper(edge[0]).edge[1:]
      let s:rhs = ':<C-U>call <SID>jump_paragraph_edge("'.direction.'", "'.edge.'", "'.mode_.'")<CR>'
      let s:cmd = mode_.'noremap <script> '.s:lhs.' '.s:rhs
      call execute(s:cmd, 'silent')
      unlet s:lhs s:rhs s:cmd
    endfor
  endfor
endfor

function! s:enable_default_maps()
  let defs = {
    \ '<down>'   : '<Plug>ParaglideDownAny',
    \ '<up>'     : '<Plug>ParaglideUpAny',
    \ '<S-down>' : '<Plug>ParaglideDownStart',
    \ '<S-up>'   : '<Plug>ParaglideUpStart',
    \ '}'        : '<Plug>ParaglideDownEnd',
    \ '{'        : '<Plug>ParaglideUpEnd',
    \ 'g<down>'  : '<Plug>ParaglideDownBlock',
    \ 'g<up>'    : '<Plug>ParaglideUpBlock',
  \ }
  for mode_ in ['n', 'v', 'o']
    for [key, value] in items(defs)
      if !hasmapto(value, mode_)
        let cmd = mode_.'map <silent><unique><nowait> '.key.' '.value
        call execute(cmd, 'silent')
      endif
    endfor
  endfor
endfunction

if s:default_maps
  call s:enable_default_maps()
endif

" Section: Testing

" xxx xxx xxx
" xxx xxx xxx
" xxx xxx xxx
" xxx xxx xxx
"
" xxxxxxxxxxx

" vim:set sw=2 sts=2:
