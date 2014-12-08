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
  $(document).imagesLoaded ->
    NProgress.done()

$(document).on 'page:restore', ->
  NProgress.remove()

