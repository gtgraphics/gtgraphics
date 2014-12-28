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
  imageMargin = $(window).scrollTop()
  windowHeight = $(window).outerHeight()
  imageHeight = windowHeight - imageMargin
  $image = $('#lightbox .lightbox-image')
  imageWindowRatio = imageHeight / windowHeight
  if imageWindowRatio < 0.3
    opacity = 0
  else
    opacity = 1
  $image.css(opacity: opacity, bottom: imageMargin)

$(document).ready ->
  $lightboxNav = $('#navbar_lightbox')
  $lightbox = $('#lightbox')

  $lightboxImageContainer = $('.lightbox-image-container', $lightbox)
  $lightboxImageContainer.hide().css(opacity: 0)

  if $lightbox.length

    # Hide carousel controls after 5 seconds if no user input happens
    $lightbox.add($lightboxNav).idleTimeoutable()

    # More beautiful image loading
    Loader.start()
    $('.lightbox-image', $lightboxImageContainer).allImagesLoaded ->
      Loader.done()
      $lightboxImageContainer.show().transition(duration: 500, opacity: 1)

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


# Scrolling

refreshNavigationScrollState = ->
  $navbar = $('#navbar_lightbox')
  $info = $('li.info', $navbar)
  $comment = $('li.comment', $navbar)

  infoHeight = $('#info').outerHeight()
  scrollTop = $(window).scrollTop()

  if scrollTop == 0
    $info.css(opacity: 1)
  else
    $info.css(opacity: 0)

  if scrollTop > infoHeight
    $comment.css(opacity: 0)
  else
    $comment.css(opacity: 1)

SCROLL_OPTIONS =
  duration: 1000
  easing: 'swing'

$(document).ready ->
  $navbar = $('#navbar_lightbox')

  $('li.info a', $navbar).click (event) ->
    event.preventDefault()
    infoHeight = $('#info').outerHeight()
    $(window).scrollTo(infoHeight, SCROLL_OPTIONS)
    $(@).blur()

  $('li.comment a', $navbar).click (event) ->
    event.preventDefault()
    $(window).scrollTo('#comments', SCROLL_OPTIONS)
    $(@).blur()

  refreshNavigationScrollState()

$(window).scroll ->
  refreshNavigationScrollState()
