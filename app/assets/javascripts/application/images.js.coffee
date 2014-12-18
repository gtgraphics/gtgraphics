$(document).ready ->
  $('#lightbox .carousel-control').on 'hotkey', ->
    url = $(@).attr('href')
    Turbolinks.visit(url)

$(document).ready ->
  $('#lightbox').idleTimeoutable()
