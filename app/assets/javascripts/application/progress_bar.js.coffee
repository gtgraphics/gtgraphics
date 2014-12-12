NProgress.configure
  showSpinner: false,
  ease: 'ease',
  speed: 500

$(document).ready ->
  NProgress.start() 
  $(document).allImagesLoaded ->
    NProgress.done()

$(window).load ->
  NProgress.done()

$(document).on 'page:fetch', -> 
  NProgress.start()

$(document).on 'page:change', ->
  $(document).allImagesLoaded ->
    NProgress.done()

$(document).on 'page:restore', ->
  NProgress.remove()
