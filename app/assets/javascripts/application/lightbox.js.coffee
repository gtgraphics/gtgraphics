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
  $image = $('#lightbox .lightbox-image')

  if window.innerWidth < 992
    $image.css(opacity: 1, bottom: 0)
    return

  imageMargin = $(window).scrollTop()
  windowHeight = $(window).outerHeight()
  imageHeight = windowHeight - imageMargin
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
    # Add hotkeys
    $('.lightbox-control', $lightbox).on 'hotkey', ->
      url = $(@).attr('href')
      Turbolinks.visit(url)

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

COMMENT_BOX_OFFSET = 20

refreshNavigationScrollState = ->
  $navbar = $('#navbar_lightbox')
  $info = $('li.info', $navbar)
  $comment = $('li.comment', $navbar)
  $enlargeImage = $('li.enlarge-image', $navbar)

  infoHeight = $('#info').outerHeight()
  scrollTop = $(window).scrollTop()

  if scrollTop >= infoHeight
    $info.hide()
    $enlargeImage.show()
  else
    $info.show()
    $enlargeImage.hide()

  if scrollTop > infoHeight + COMMENT_BOX_OFFSET
    $comment.hide()
  else
    $comment.show()

$(document).ready ->
  refreshNavigationScrollState()

  $('#navbar_lightbox li.info a').click (event) ->
    event.preventDefault()
    options = _($(@).data()).defaults(duration: 500, easing: 'swing')
    infoHeight = $('#info').outerHeight()
    $(window).scrollTo(infoHeight, options)

$(window).scroll ->
  refreshNavigationScrollState()
