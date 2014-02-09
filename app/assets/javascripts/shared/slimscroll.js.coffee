DEFAULTS = 
  height: 'auto'
  allowPageScroll: true

$(document).ready ->
  $('.slimscroll').slimScroll(DEFAULTS)

$(window).resize ->
  $('.slimscroll').slimScroll(DEFAULTS)

#$(document).on 'page:receive', ->
#  $slimScroll = $('.slimscroll')
#  $slimScroll.slimScroll(destroy: true)

#$(document).on 'page:change', ->
#  $slimScroll = $('.slimscroll')
#  $slimScroll.slimScroll(DEFAULTS)  