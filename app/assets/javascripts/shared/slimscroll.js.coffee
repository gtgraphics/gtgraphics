DEFAULTS = 
  height: 'auto'
  allowPageScroll: true

jQuery.prepare ->
  $('.slimscroll').slimScroll(DEFAULTS)

$(window).resize ->
  $('.slimscroll').slimScroll(DEFAULTS)

$(window).scroll ->
  $('.slimscroll').slimScroll(DEFAULTS)