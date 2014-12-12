$(document).ready ->
  $carousel = $('.fullscreen-carousel')

  $carousel.carousel(interval: false, pause: false)

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
    $img.remove()

  $(window).on 'resize', ->
    $carousel.css
      width: $(window).outerWidth()
      height: $(window).outerHeight()

