$(document).ready ->

  $gallery = $('#gallery').css(opacity: 0)

  $gallery.imagesLoaded().always ->
    $gallery.masonry
      itemSelector: '.brick'
      columnWidth: (containerWidth) ->
        Math.round(containerWidth / 3)
      gutter: 20
      animate: false
    $gallery.animate(opacity: 1)


  if $gallery.length

    scrollOptions =
      navSelector: '#pagination' # selector for the paged navigation
      nextSelector: '#pagination #next_page' # selector for the NEXT link (to page 2)
      itemSelector: '.brick' # selector for all items you'll retrieve
      maxPage: $gallery.data('totalPages')
      loading:
        start: ->
          NProgress.start()
          scroller = $gallery.data('infinitescroll')
          scroller.beginAjax(scroller.options)
        finished: ->
          scroller = $gallery.data('infinitescroll')
          NProgress.done()
      errorCallback: (state) ->
        NProgress.done()

    $(scrollOptions.navSelector).hide()

    $gallery.infinitescroll(scrollOptions,
      # trigger Masonry as a callback
      (newElements) ->

        # hide new items while they are loading
        $newElems = $(newElements).css(opacity: 0)
        
        # ensure that images load before adding to masonry layout
        $newElems.imagesLoaded().always ->
          
          NProgress.done()

          # show elems now they're ready
          $newElems.animate(opacity: 1)
          $gallery.masonry('appended', $newElems, true)
    )

    # Dirty hack because infinite scroll does not seem to provide any kind of hook


$(document).on 'page:fetch', ->
  $('#gallery').infinitescroll('destroy')