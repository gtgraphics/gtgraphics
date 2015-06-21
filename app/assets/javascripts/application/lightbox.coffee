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

resizeImage = ->
  $lightbox = $('.lightbox-with-details')
  $image = $('.lightbox-image', $lightbox)
  $controls = $('.lightbox-controls', $lightbox)
  $elements = $image.add($controls)

  if $.device.isExtraSmall() || $.device.isSmall()
    $elements.css(bottom: '').removeClass('ghost')
  else
    imageMargin = $(window).scrollTop()
    $elements.css(bottom: imageMargin)
    if imageIsDisplayed()
      $elements.removeClass('ghost')
    else
      $elements.addClass('ghost')

imageIsDisplayed = ->
  imageMargin = $(window).scrollTop()
  windowHeight = $(window).outerHeight()
  imageHeight = windowHeight - imageMargin
  imageWindowRatio = imageHeight / windowHeight
  imageWindowRatio >= 0.33

$(document).ready ->
  $lightbox = $('.lightbox')

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
    $timeoutables.idleTimeoutable
      idleClass: 'unobstrusive',
      awakeOn: ['keydown', 'mousemove'],
      if: -> $(window).scrollTop() == 0

    $('.dropdown', $navbar)
      .on 'shown.bs.dropdown', -> $timeoutables.idleTimeoutable('stop')
      .on 'hidden.bs.dropdown', -> $timeoutables.idleTimeoutable('start')

    # Touch Swipe
    $lightboxControls.swipe
      tap: (event, target) ->
        event.preventDefault()
        event.stopPropagation()
        unless $('.dropdown.open').length
          $timeoutables.each ->
            $(@).idleTimeoutable('toggle')
      swipeLeft: ->
        slide($lightbox, false) if $.device.isExtraSmall() || $.device.isSmall()
      swipeRight: ->
        slide($lightbox, true) if $.device.isExtraSmall() || $.device.isSmall()
      threshold: 80

    # More beautiful image loading
    $fadedElements = $('#lightbox_page_wrapper, #nav_lightbox_actions').add($lightboxImageContainer)
    $fadedElements.hide().css(opacity: 0)
    Loader.start()
    $lightboxImage.allImagesLoaded ->
      $fadedElements.show().transition(duration: 500, opacity: 1)
      refreshNavigationScrollState()
      Loader.done()

    resizeImage()

$(window).scroll ->
  resizeImage()

$(window).resize ->
  resizeImage()


# Scrolling

COMMENT_BOX_OFFSET = 20

refreshNavigationScrollState = ->
  $nav = $('#nav_lightbox_actions')
  $info = $('li.info', $nav)
  $comment = $('li.comment', $nav)
  $enlargeImage = $('li.enlarge-image', $nav)

  infoHeight = $('#info').outerHeight()
  scrollTop = $(window).scrollTop()

  if scrollTop >= infoHeight
    $info.hide()
    $enlargeImage.show()
  else
    $info.show()
    $enlargeImage.hide()

  if scrollTop > (infoHeight + COMMENT_BOX_OFFSET)
    $comment.hide()
  else
    $comment.show()

navigationIsFix = ->
  return false if $.device.isExtraSmall() || $.device.isSmall()
  $navbar = $('#navbar_lightbox')
  navbarHeight = $navbar.outerHeight()
  scrollTop = $(window).scrollTop()
  windowHeight = $(window).outerHeight()
  scrollTop > (windowHeight - navbarHeight)

refreshNavigationDisplayState = ->
  $navbar = $('#navbar_lightbox')
  if navigationIsFix()
    navbarHeight = $navbar.outerHeight()
    scrollTop = $(window).scrollTop()
    windowHeight = $(window).outerHeight()
    delta = windowHeight - scrollTop - navbarHeight
    $navbar.css(marginTop: delta)
  else
    $navbar.css(marginTop: '')

$(document).ready ->
  $('#navbar_lightbox li.info a').click (event) ->
    event.preventDefault()
    options = _($(@).data()).defaults(duration: 500, easing: 'swing')
    infoHeight = $('#info').outerHeight()
    $(window).scrollTo(infoHeight, options)

  refreshNavigationDisplayState()

$(window).scroll ->
  refreshNavigationScrollState()
  refreshNavigationDisplayState()

$(window).resize ->
  refreshNavigationDisplayState()
