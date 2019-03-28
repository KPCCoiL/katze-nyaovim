if exists('g:loaded_katze_latex') || !exists('g:nyaovim_version')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let g:katze_align_environment = ['align', 'align*']
let g:katze_math_environment = ['gather', 'displaymath', 'equation', 'equation*']
let g:katze_min_width = "500px"

if exists('g:katze_commands') && g:katze_commands
  command! -nargs=* KatzeOpen call katze#openPreview(<f-args>)
  command! KatzeClose call katze#closePreview()
  command! KatzeSendMath call katze#sendMath()
  command! -range KatzeSendRange call katze#sendRange(<line1>, <line2>)
  command! KatzeStartAutoPreview call katze#startAutoPreview()
  command! KatzeStopAutoPreview call katze#stopAutoPreview()
  command! KatzeToggleAutoPreview call katze#toggleAutoPreview()
endif

let &cpo = s:save_cpo
let g:loaded_katze_latex = 1
