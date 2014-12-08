TRANSITION_DURATION = 200


$(document).on 'page:before-unload', ->
  $('#page_content').animate(opacity: 0)
  $('#background').animate(opacity: 0)

$(document).on 'page:load', ->
  $('#page_content').css(opacity: 0).animate(opacity: 'inherit')
  
  $background = $('#background')
  $background.hide().imagesLoaded ->
    $background.fadeIn(400)
