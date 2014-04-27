$(document).ready ->
  $frame = $('#editor_frame').hide()
  $frame.load ->
    $frame.fadeIn('fast')
