NProgress.configure
  showSpinner: false,
  ease: 'ease',
  speed: 500

$(document).on 'page:fetch', ->
  NProgress.start()

$(document).on 'page:change', ->
  NProgress.done()

$(document).on 'page:restore', ->
  NProgress.remove()
