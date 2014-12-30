slide = ($lightbox, prev) ->
  $controls = $lightbox.find('.lightbox-control')
  if prev
    $control = $controls.filter('.left')
  else
    $control = $controls.filter('.right')
  return false unless $control.length
  url = $control.attr('href')
  Turbolinks.visit(url)

repositionCaption = ->
  $captionContainer = $('#lightbox_page_wrapper')
  windowHeight = $(window).outerHeight()
  $captionContainer.css(top: windowHeight)

resizeImage = ->
  $lightbox = $('#lightbox')
  $image = $('.lightbox-image', $lightbox)
  $controls = $('.lightbox-controls', $lightbox)
  $elements = $image.add($controls)

  if window.innerWidth < 992
    $elements.css(bottom: 0)
    return

  imageMargin = $(window).scrollTop()
  windowHeight = $(window).outerHeight()
  imageHeight = windowHeight - imageMargin
  imageWindowRatio = imageHeight / windowHeight

  $elements.css(bottom: imageMargin)
  if imageWindowRatio < 0.33
    $elements.addClass('ghost')
  else
    $elements.removeClass('ghost')

$(document).ready ->
  $lightboxNav = $('#navbar_lightbox')
  $lightbox = $('#lightbox')
  $lightboxControls = $('.lightbox-controls', $lightbox)

  $lightboxImageContainer = $('.lightbox-image-container', $lightbox)
  $lightboxImageContainer.hide().css(opacity: 0)

  if $lightbox.length
    # Add hotkeys
    $('.lightbox-control', $lightbox).on 'hotkey', ->
      url = $(@).attr('href')
      Turbolinks.visit(url)

    $lightboxImage = $('.lightbox-image', $lightboxImageContainer)

    # Hide carousel controls after 5 seconds if no user input happens
    $timeoutables = $lightbox.add($lightboxNav)
    $timeoutables.idleTimeoutable()

    $('.dropdown', $lightboxNav)
      .on 'shown.bs.dropdown', -> $timeoutables.idleTimeoutable('stop')
      .on 'hidden.bs.dropdown', -> $timeoutables.idleTimeoutable('start')

    # More beautiful image loading
    Loader.start()
    $lightboxImage.allImagesLoaded ->
      Loader.done()
      $lightboxImageContainer.show().transition(duration: 500, opacity: 1)

    # Add swipe for mobile devices
    $('.lightbox-controls', $lightbox).swipe
      swipe: (event, direction) ->
        return false if window.innerWidth >= 992
        prev = (direction == 'right')
        return unless prev or direction == 'left'
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
