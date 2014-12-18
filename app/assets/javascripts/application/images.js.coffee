$(document).ready ->
  $('#lightbox .carousel-control').on 'hotkey', ->
    url = $(@).attr('href')
    Turbolinks.visit(url)

$(document).ready ->
  $lightbox = $('#lightbox')

  if $lightbox.length

    # Hide carousel controls after 5 seconds if no user input happens
    $lightbox.idleTimeoutable()

    # Allow navigation in the gallery via mousewheel
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
