$(document).ready ->
  $('#lightbox .carousel-control').on 'hotkey', ->
    url = $(@).attr('href')
    Turbolinks.visit(url)

$(document).ready ->
  $lightbox = $('#lightbox')
  $lightboxImageContainer = $('.lightbox-image-container', $lightbox)
  $lightboxImageContainer.hide().css(opacity: 0)

  if $lightbox.length

    # Hide carousel controls after 5 seconds if no user input happens
    $lightbox.idleTimeoutable()

    # Allow navigation in the gallery via mousewheel
    $lightbox.mousewheel (event) ->
      $controls = $lightbox.find('.carousel-control')
      right = event.deltaY < 0
      if right
        $control = $controls.filter('.right')
      else
        $control = $controls.filter('.left')
      url = $control.attr('href')
      Turbolinks.visit(url)

    # More beautiful image loading
    Loader.start()
    $lightboxImageContainer.allImagesLoaded ->
      Loader.done()
      $lightboxImageContainer.show().animate(opacity: 1)

    # Add swipe for mobile devices
    $lightbox.swipe
      swipe: (event, direction) ->
        $controls = $lightbox.find('.carousel-control')
        switch direction
          when 'left'
            $control = $controls.filter('.right')
          when 'right'
            $control = $controls.filter('.left')
        if $control and $control.length
          url = $control.attr('href')
          Turbolinks.visit(url)
