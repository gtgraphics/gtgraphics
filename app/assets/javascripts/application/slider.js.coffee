$(document).ready ->
  $carousel = $('#slider')

  $carousel.carousel(interval: false, pause: false)

  # Make carousel images cover the whole background
  $carousel.css
    margin: 0
    width: $(window).outerWidth()
    height: $(window).outerHeight()

  $carousel.find('.item').css
    position: 'fixed'
    width: '100%'
    height: '100%'

  $carousel.find('.carousel-inner .item img').each ->
    $img = $(@)
    imgSrc = $img.attr('src')
    $img.parent().css
      background: 'url(' + imgSrc + ') center center no-repeat'
      '-webkit-background-size': '100% '
      '-moz-background-size': '100%'
      '-o-background-size': '100%'
      'background-size': '100%'
      '-webkit-background-size': 'cover'
      '-moz-background-size': 'cover'
      '-o-background-size': 'cover'
      'background-size': 'cover'
      
    # loader acts crazy when removing the image,
    # so we will only hide it as a workaround
    $img.hide()

  $(window).on 'resize', ->
    $carousel.css
      width: $(window).outerWidth()
      height: $(window).outerHeight()

  # TODO Switch to next or previous slice when using scroll wheel