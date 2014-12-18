NProgress.configure
  showSpinner: false,
  ease: 'ease',
  speed: 500

$(document).ready ->
  NProgress.start()

$(window).load ->
  NProgress.done()

$(document).on 'page:fetch', ->
  NProgress.start()

$(document).on 'page:change', ->
  $carousel = $('#cover_carousel')
  if $carousel.length
    $(document).on 'init.gtg.carousel', ->
      NProgress.done()
  else
    $(document).allImagesLoaded ->
      NProgress.done()

$(document).on 'page:restore', ->
  NProgress.remove()
  Loader.remove()
