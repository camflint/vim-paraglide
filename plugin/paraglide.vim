" paraglide.vim - Provides paragraph beginning and ending markers
" Maintainer: Cameron Flint <dev@caflint.fastmail.com>
" Version: 1.0
" License: MIT

" Section: Global data.

if get(g:, 'loaded_paraglide', 0) || &cp
  finish
endif
let g:loaded_paraglide = 1

" When entering visual mode, we change the updatetime->0 and then change it back
" when reentering normal mode. This is a hack used to detect when the user
" leaves visual mode.
" let s:saved_updatetime = v:null

" When entering visual mode, we save the beginning cursor position so that we
" can maintain the highlighting while navigating paragraphs.
" let s:saved_visual_marks = {}

" Section: Functions

const s:re_empty_line = '\v^\s*$'
const s:re_nonempty_line = '\v^\s*[^\s]+.*$'

" function! s:enter_visual_mode()
"   let s:saved_updatetime = &updatetime 
"   let &updatetime = 0
"   let s:saved_visual_marks[bufnr()] = getcurpos()
"   return '' " Return nothing to no-op.
" endfunction

" function! s:exit_visual_mode()
"   " echom 'VISUALENTER: clear curpos for buffer '.bufnr()
"   let s:saved_visual_marks[bufnr()] = v:null
"   if !empty(s:saved_updatetime)
"     let &updatetime = s:saved_updatetime
"     let s:saved_updatetime = v:null
"   endif
"   return '' " Return nothing to no-op.
" endfunction

function! s:get_top_bottom_edge()
  const line = line('.')
  const at_top = (line == 1) || (getline(line - 1) =~ s:re_empty_line)
  const at_bottom = (line == line('$')) || (getline(line + 1) =~ s:re_empty_line)
  return [at_top, at_bottom]
endfunction

" direction=down|up, edge=start|end|any
function! s:jump_paragraph_edge(direction, edge, mode)
  const down = a:direction ==# 'down'
  const up = !down
  const start = a:edge ==# 'start'
  const end = a:edge ==# 'end'
  const any = !start && !end

  const dirsign = down ? 1 : -1
  const flags = 'W' . (down ? '' : 'b')
  const saved_pos = getcurpos()
  const [_bufnum, saved_linenum, saved_col; _rest] = saved_pos
  const viz = tolower(a:mode) =~ '\v^[vs]$'

  " Restore visual mode.
  if viz
    normal gv
  endif

  " Jump out of the current paragraph if we need to.
  let jump_out = v:false
  if getline('.') =~ s:re_nonempty_line
    let [at_top_edge, at_bottom_edge] = s:get_top_bottom_edge()
    if (down && at_bottom_edge) || (up && at_top_edge)
      let jump_out = v:true
    elseif !any && ((down && !end) || (up && !start))
      let jump_out = v:true
    endif
  endif
  if jump_out
    if !search(s:re_empty_line, flags) | return | endif
  endif

  " Make sure we land in a paragraph.
  if getline('.') =~ s:re_empty_line
    if !search(s:re_nonempty_line, flags) | return | endif
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
    const re_boundary = s:re_empty_line . (down ? '|%$' : '|%^')
    if search(re_boundary, flags) && getline('.') =~ s:re_empty_line
      call cursor(line('.') - dirsign, 1)
    endif
  endif

  " Restore selection, if needed.
  "if viz && !empty(s:saved_visual_marks[bufnr()])
  "  let tmp = s:saved_visual_marks[bufnr()]
  "  let tmp2 = getcurpos()
  "  " echom 'Select range ['.tmp[1].','.tmp[2].'] to ['.tmp2[1].','.tmp2[2].'] for buffer '.bufnr()
  "  call setpos("'a", s:saved_visual_marks[bufnr()])
  "  call execute('normal ' . visualmode() . "'a'")
  "  "let s:saved_visual_marks[bufnr()] = v:null
  "endif

  " Restore column, off, and curswant.
  " This is necessary because we had to change the cursor position for search()s.
  let pos = saved_pos
  let pos[1] = getpos('.')[1] " At the end, we'll have only moved the line number.
  call setpos('.', pos)
  " echom '[END] jump_paragraph_edge'
endfunction

" Section: Maps

for mode_ in ['n', 'v', 'o']
  for direction in ['down', 'up']
    for edge in ['start', 'end', 'any']
      let s:lhs = '<Plug>Paraglide'.toupper(direction[0]).direction[1:].toupper(edge[0]).edge[1:]
      let s:rhs = ':<C-U>call <SID>jump_paragraph_edge("'.direction.'", "'.edge.'", "'.mode_.'")<CR>'
      let s:cmd = mode_.'noremap <script> '.s:lhs.' '.s:rhs
      " echom s:cmd
      call execute(s:cmd, 'silent')
      unlet s:lhs s:rhs s:cmd
    endfor
  endfor
endfor

function! s:default_maps()
  let definitions = {
          \ '<down>': '<Plug>ParaglideDownStart',
          \ '<up>': '<Plug>ParaglideUpStart',
          \ 'g<down>': '<Plug>ParaglideDownAny',
          \ 'g<up>' : '<Plug>ParaglideUpAny',
          \ '}' : '<Plug>ParaglideDownEnd',
          \ '{' : '<Plug>ParaglideUpEnd'
        \ }
  for mode_ in ['n', 'v', 'o']
    for [key, value] in items(definitions)
      if !hasmapto(value, mode_)
        let cmd = mode_.'map <silent><unique><nowait> '.key.' '.value
        " echom cmd
        call execute(cmd, 'silent')
      endif
    endfor
  endfor
endfunction

" Hook v, V, and C-v.
" vnoremap <expr> <SID>EnterVisualMode <SID>enter_visual_mode()
" nnoremap <script> v v<SID>EnterVisualMode
" nnoremap <script> V V<SID>EnterVisualMode
" nnoremap <script> <C-v> <C-v><SID>EnterVisualMode

" Hook exit visual mode (actually, enter normal mode).
" augroup EnterVisualMode
"   autocmd!
"   autocmd CursorHold * call <SID>exit_visual_mode()
" augroup END

if get(g:, 'paraglide_default_maps', 1) == 1
  call s:default_maps()
endif

" vim:set sw=2 sts=2:
