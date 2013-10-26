$.fn.editor = (options = {}) ->
  @each ->
    $input = $(@)
    new Editor($input, options)

$(document).ready ->
  $('.editor').editor()
