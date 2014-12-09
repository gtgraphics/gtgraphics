TRANSITION_DURATION = 200

prepareBackground = ->
  $background = $('#background')
  $background.allImagesLoaded ->
    $background.addClass('in')

$(document).on 'page:receive', ->
  $('#background').removeClass('in')

$(document).ready ->
  prepareBackground()

$(document).on 'page:restore', ->
  prepareBackground()
