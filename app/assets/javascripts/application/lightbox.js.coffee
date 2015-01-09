slide = ($lightbox, prev) ->
  $controls = $lightbox.find('.lightbox-control')
  if prev
    $control = $controls.filter('.left')
  else
    $control = $controls.filter('.right')
  return false unless $control.length
  url = $control.attr('href')
  # TODO Some fancy effect
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
  $lightbox = $('#lightbox')

  if $lightbox.length
    $navbar = $('#navbar_lightbox')
    $lightboxControls = $('.lightbox-controls', $lightbox)
    $lightboxImageContainer = $('.lightbox-image-container', $lightbox)

    # Add hotkeys
    $('.lightbox-control', $lightbox).on 'hotkey', ->
      url = $(@).attr('href')
      Turbolinks.visit(url)

    $lightboxImage = $('.lightbox-image', $lightboxImageContainer)

    # Hide carousel controls after 5 seconds if no user input happens
    $timeoutables = $lightbox.add($navbar)
    $timeoutables.idleTimeoutable(idleClass: 'unobstrusive', awakeOn: 'mousemove')

    $('.dropdown', $navbar)
      .on 'shown.bs.dropdown', -> $timeoutables.idleTimeoutable('stop')
      .on 'hidden.bs.dropdown', -> $timeoutables.idleTimeoutable('start')

    $('.lightbox-controls', $lightbox).click (event) ->
      $timeoutables.idleTimeoutable('toggle') unless $('.dropdown.open').length

    # More beautiful image loading
    $fadedElements = $('#lightbox, #lightbox_page_wrapper, #nav_lightbox_actions')
    $fadedElements.hide().css(opacity: 0)
    Loader.start()
    $lightboxImage.allImagesLoaded ->
      $fadedElements.show().transition(duration: 500, opacity: 1)
      refreshNavigationScrollState()
      Loader.done()

    # Add swipe for mobile devices
    if $('html').hasClass('touch') # TODO: Use Modernizr builtin support
      $('.lightbox-controls', $lightbox).swipe
        swipeLeft: ->
          slide($lightbox, false) if window.innerWidth < 992
        swipeRight: ->
          slide($lightbox, true) if window.innerWidth < 992

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
  $navbar = $('#nav_lightbox_actions')
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
  $('#navbar_lightbox li.info a').click (event) ->
    event.preventDefault()
    options = _($(@).data()).defaults(duration: 500, easing: 'swing')
    infoHeight = $('#info').outerHeight()
    $(window).scrollTo(infoHeight, options)

$(window).scroll ->
  refreshNavigationScrollState()

