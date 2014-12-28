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

repositionCaption = ->
  $captionContainer = $('#lightbox_page_wrapper')
  $title = $('.lightbox-title', $captionContainer)
  windowHeight = $(window).outerHeight()
  titleHeight = $title.outerHeight()
  titleHeight = 0
  $captionContainer.css(top: windowHeight - titleHeight)

resizeImage = ->
  scrollTop = $(window).scrollTop()
  $('#lightbox .lightbox-image').css(marginBottom: scrollTop)

$(document).ready ->
  $lightbox = $('#lightbox')
  $lightboxImageContainer = $('.lightbox-image-container', $lightbox)
  $lightboxImageContainer.hide().css(opacity: 0)

  if $lightbox.length

    # Hide carousel controls after 5 seconds if no user input happens
    $lightbox.idleTimeoutable()

    # More beautiful image loading
    Loader.start()
    $('.lightbox-image', $lightboxImageContainer).allImagesLoaded ->
      Loader.done()
      $lightboxImageContainer.show().animate(opacity: 1)

    # Add swipe for mobile devices
    if Modernizr.touch
      $lightboxImageContainer.swipe
        swipe: (event, direction) ->
          prev = (direction == 'left')
          return unless prev or direction == 'right'
          slide($lightbox, prev)

    # Position caption container
    repositionCaption()
    resizeImage()

$(window).scroll ->
  resizeImage()

$(window).resize ->
  repositionCaption()
  resizeImage()

# $(window).scroll ->
#   windowHeight = $(window).outerHeight()
#   scrollY = $(window).scrollTop()

#   scrollRatio = 1 - (scrollY / windowHeight)

#   $image = $('.lightbox-image')
#   $image.css(opacity: scrollRatio)
