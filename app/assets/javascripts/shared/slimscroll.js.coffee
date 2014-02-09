jQuery.prepare ->
  $('.slimscroll').slimScroll(height: 'auto')

$(window).resize ->
  $('.slimscroll').slimScroll(height: 'auto')

$(window).scroll ->
  $('.slimscroll').slimScroll(height: 'auto')