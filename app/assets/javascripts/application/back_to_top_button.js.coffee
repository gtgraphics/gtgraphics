$(document).ready ->
  $backToTop = $('#back_to_top')
  $backToTop.affix(offset: { top: 300 }).trigger('scroll')
  $backToTop.click (event) ->
    event.preventDefault()
    $(document).scrollTo({ top: 0, left: 0 }, 800)