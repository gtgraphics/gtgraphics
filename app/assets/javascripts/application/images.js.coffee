$(document).ready ->
  $('#lightbox .carousel-control').on 'hotkey', ->
    url = $(@).attr('href')
    Turbolinks.visit(url)

slide = ($lightbox, prev) ->
  $controls = $lightbox.find('.carousel-control')
  if prev
    $control = $controls.filter('.left')
  else
    $control = $controls.filter('.right')
  url = $control.attr('href')
  Turbolinks.visit(url)

$(document).ready ->
  $lightbox = $('#lightbox')
  $lightboxImageContainer = $('.lightbox-image-container', $lightbox)
  $lightboxImageContainer.hide().css(opacity: 0)

  if $lightboxImageContainer.length

    # Hide carousel controls after 5 seconds if no user input happens
    $lightboxImageContainer.idleTimeoutable()

    # Allow navigation in the gallery via mousewheel
    # $lightbox.mousewheel (event) ->
    #   return if event.deltaY == 0
    #   slide($lightbox, event.deltaY > 0)

    # More beautiful image loading
    Loader.start()
    $lightboxImageContainer.allImagesLoaded ->
      Loader.done()
      $lightboxImageContainer.show().animate(opacity: 1)

    # Add swipe for mobile devices
    $lightboxImageContainer.swipe
      swipe: (event, direction) ->
        prev = (direction == 'left')
        return unless prev or direction == 'right'
        slide($lightbox, prev)
