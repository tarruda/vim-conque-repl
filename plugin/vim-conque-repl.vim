if !exists('g:conque_repl_send_key')
  let g:conque_repl_send_key = '<F5>'
endif

if !exists('g:conque_repl_send_buffer_key')
  let g:conque_repl_send_buffer_key = '<F6>'
endif

let s:locked = 0
" Based on 'conque_term#send_selected'
fun! s:send_text(mode, all) 
  if s:locked
    return
  endif
  let s:locked = 1
  " Conque sets the 'updatetime' option to 50 in order to use the 
  " CursorHold hack to poll for program output and update the terminal
  " buffer.
  " The value of update_time is saved, since switching buffers with
  " the 'sb' command doesn't trigger the events conqueshell needs to restore
  " updatetime to its sane value, and making changes to the file buffer would
  " cause a lot of swap writes(:h updatetime).
  let saved_updatetime = &updatetime
  " get current buffer name
  let buffer_name = expand('%')
  " get most recent/relevant terminal
  let term = conque_term#get_instance()
  " Test the current mode to paste correctly in the term
  if a:mode == 2
    " Visual mode, get lines selected and if needed, strip the start/end 
    " of the first/last lines respectively.
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let text = getline(lnum1, lnum2)
    let text[0] = text[0][col1-1 :]
    let text[-1] = text[-1][: col2-1]
  else
    if a:all
      let text = getline(1,'$')
    else
      let text = [getline('.')]
    endif
  endif
  call term.focus()
  for line in text
    call term.writeln(line)
  endfor
  " scroll buffer left
  startinsert!
  normal! 0zH
  " If the buffers were switched in the current call stack, the terminal
  " buffer would not be updated, and the eval results would not be visible. 
  call s:after_ui_refresh('s:switch_buffer', [buffer_name, a:mode, saved_updatetime])
endfun

fun! s:switch_buffer(buffer_name, mode, saved_updatetime) 
  augroup conque_repl_timeout
    autocmd!
  augroup END
  let &updatetime = a:saved_updatetime
  let save_sb = &switchbuf
  sil set switchbuf=usetab
  exe 'sb ' . a:buffer_name
  let &switchbuf = save_sb
  if a:mode > 0
    stopinsert " Stop insert if was in normal or visual mode
    if a:mode == 2
      " Reselect previous selected text
      normal! gvl
    endif
  endif
  let s:locked = 0
endfun

fun! s:after_ui_refresh(F, args)
  let s:temp_function_name = a:F
  let s:temp_function_args = a:args
  augroup conque_repl_timeout
    autocmd!
    autocmd CursorHoldI * call call(s:temp_function_name, s:temp_function_args)
  augroup END
endfun

command! ConqueTermSendLineInsert :call s:send_text(0, 0)
command! ConqueTermSendLineNormal :call s:send_text(1, 0)
command! -range ConqueTermSendSelection :call s:send_text(2, 0) 
command! ConqueTermSendBufferInsert :call s:send_text(0, 1) 
command! ConqueTermSendBufferNormal :call s:send_text(1, 1) 

if g:conque_repl_send_key != '' && ! maparg(g:conque_repl_send_key)
  exe 'inoremap <silent>' g:conque_repl_send_key '<ESC>:ConqueTermSendLineInsert<CR>'
  exe 'nnoremap <silent>' g:conque_repl_send_key ':ConqueTermSendLineNormal<CR>'
  exe 'vnoremap <silent>' g:conque_repl_send_key ':ConqueTermSendSelection<CR>'
en

if g:conque_repl_send_buffer_key != '' && ! maparg(g:conque_repl_send_buffer_key)
  exe 'inoremap <silent>' g:conque_repl_send_buffer_key '<ESC>:ConqueTermSendBufferInsert<CR>'
  exe 'nnoremap <silent>' g:conque_repl_send_buffer_key ':ConqueTermSendBufferNormal<CR>'
en
