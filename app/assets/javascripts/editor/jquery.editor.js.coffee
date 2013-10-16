$.fn.editor = (options = {}) ->
  @each ->
    new Editor($(@), options)

$(document).ready ->
  $('.editor').editor()
