$.fn.editor = (options = {}) ->
  @each ->
    $input = $(@)
    new Editor($input, options)

#$(document).ready ->
$(window).load ->
  $('.editor').editor()
