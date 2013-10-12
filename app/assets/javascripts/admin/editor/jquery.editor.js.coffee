$.fn.editor = ->
  @each ->
    new Editor($(@))

$(document).ready ->
  $('.editor').editor()
