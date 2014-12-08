TRANSITION_DURATION = 200

$(document).on 'page:receive', ->
  $('#page_content').animate(opacity: 0)
  $('#background img').animate(opacity: 0)

$(document).on 'page:load', ->
  $('#page_content').css(opacity: 0).animate(opacity: 1)
  
$(document).ready ->
  $background = $('#background img')
  $background.css(opacity: 0).imagesLoaded().always ->
    $background.animate({ opacity: 1 }, 400)
