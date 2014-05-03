$(document).ready ->
  $frame = $('#editor_frame').hide()
  $frame.load ->
    $frame.fadeIn('fast')

    # Start here
    console.log 'loaded'

    $frame.contents().find('.region').attr('contenteditable', true)

