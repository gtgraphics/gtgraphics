TRANSITION_DURATION = 200

$(document).on 'page:receive', ->
  $('#background').removeClass('in')

$(document).ready ->
  $background = $('#background')
  $background.imagesLoaded().always ->
    $background.addClass('in')

$(document).on 'page:restore', ->
  $background = $('#background')
  $background.imagesLoaded().always ->
    $background.addClass('in')
