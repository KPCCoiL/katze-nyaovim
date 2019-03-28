let s:save_cpo = &cpo
set cpo&vim

function! katze#sendRange(start, last)
  let math = join(getline(a:start, a:last))
  call rpcnotify(0, 'katze:send_math', math)
endfunction

function! katze#getMath(delims)
  let begin_pattern = '\V\%(' . join(map(copy(a:delims), '"\\(" . v:val[0] . "\\)"'), '\|') . '\)'
  let [begin_line, begin_col, begin_match] = searchpos(begin_pattern, 'bcenpW')
  if begin_match < 2
    return [-1, '']
  endif
  let end_pattern = '\V' . a:delims[begin_match - 2][1]
  let [end_line, end_col] = searchpos(end_pattern , 'cnW')
  if end_line == 0 && end_col == 0
    let end_line = line('$')
    let end_col = strlen(getline('$')) + 1
  endif
  let el_len = strlen(getline(end_line))
  return [begin_match - 2, join(getline(begin_line, end_line))[begin_col : end_col - el_len - 2]]
endfunction

function! katze#sendMath()
  let envs = g:katze_align_environment + g:katze_math_environment
  let env_pats = map(envs, '["\\\\begin{" . v:val . "}", "\\\\end{" . v:val . "}"]')
  let math_pats = env_pats + [['\\[', '\\]'], ['\\(', '\\)'], ['$', '$']]
  let g:katze_math_pats = math_pats
  let [found, math] = katze#getMath(math_pats)
  if found < len(g:katze_align_environment)
    let math = '\begin{aligned}' . math . '\end{aligned}'
  endif
  call rpcnotify(0, 'katze:send_math', math)
endfunction

let s:doing_preview = 0

function! katze#startAutoPreview()
  let s:doing_preview = 1
  augroup katze_auto_preview
    autocmd!
    autocmd TextChanged,TextChangedI,TextChangedP * call katze#sendMath()
  augroup END
endfunction

function! katze#stopAutoPreview()
  let s:doing_preview = 0
  augroup katze_auto_preview
    autocmd!
  augroup END
endfunction

function! katze#toggleAutoPreview()
  if s:doing_preview
    call katze#stopAutoPreview()
  else
    call katze#startAutoPreview()
  endif
endfunction

function! katze#openPreview(...)
  if a:0 < 2
    let port = 3303
  else
    let port = str2nr(a:2)
  endif
  if a:0 < 1
    let minWidth = '600px'
  else
    let minWidth = a:1
  endif
  call rpcnotify(0, 'katze:open', minWidth, port)
endfunction

function! katze#closePreview()
  call rpcnotify(0, 'katze:close')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
