$(document).ready ->
  $('#lightbox .carousel-control').on 'hotkey', ->
    url = $(@).attr('href')
    Turbolinks.visit(url)

$(document).ready ->
  $lightbox = $('#lightbox')
  $lightbox.idleTimeoutable()

  $lightbox.mousewheel (event) ->
    $controls = $(@).find('.carousel-control')
    right = event.deltaY < 0
    if right
      $control = $controls.filter('.right')
    else
      $control = $controls.filter('.left')
    url = $control.attr('href')
    Turbolinks.visit(url)

  # More beautiful image loading
  $lightboxImage = $('.lightbox-image', $lightbox).hide().css(opacity: 0)
  Loader.start()
  $lightboxImage.allImagesLoaded ->
    Loader.done()
    $lightboxImage.show().animate(opacity: 1)
