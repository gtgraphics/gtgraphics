TRANSITION_DURATION = 200

$(document).on 'page:fetch', ->
  $('#page_content').animate(opacity: 0)
  $('#background').animate(opacity: 0)
  console.log 'bla'


$(document).on 'page:load', ->
  $('#page_content').css(opacity: 0).animate(opacity: 'inherit')
  
$(document).ready ->
  $background = $('#background')
  $background.css(opacity: 0).imagesLoaded().always ->
    $background.animate({ opacity: 'inherit' }, 400)
