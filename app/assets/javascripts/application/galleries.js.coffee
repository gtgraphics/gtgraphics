$(document).on 'page:change', ->
  $gallery = $('#gallery').css(opacity: 0)

  # Prepare infinite scroller
  scrollOptions =
    navSelector: '#pagination' # selector for the paged navigation
    nextSelector: '#pagination #next_page' # selector for the NEXT link (to page 2)
    itemSelector: '.gallery-item' # selector for all items you'll retrieve
    maxPage: $gallery.data('totalPages')
    loading:
      start: ->
        NProgress.start()
        scroller = $gallery.data('infinitescroll')
        scroller.beginAjax(scroller.options)
      finished: ->
        NProgress.done()
    errorCallback: (state) ->
      NProgress.done()

  $(scrollOptions.navSelector).hide()

  # Image 

  $gallery.allImagesLoaded ->
    $gallery.animate(opacity: 1)
    $gallery.masonry
      itemSelector: '.gallery-item'
      columnWidth: (containerWidth) ->
        Math.floor(containerWidth / 3.0)
      gutter: 20
      animate: false

  # Apply infinite scroller to masonry
  $gallery.infinitescroll scrollOptions, (html) ->
    $appendedElements = $(html).css(opacity: 0)
    $appendedElements.allImagesLoaded ->
      $appendedElements.animate(opacity: 1)
      $gallery.append($appendedElements)
      $gallery.masonry 'appended', $appendedElements, ->
        NProgress.done()


$(document).on 'page:before-unload page:receive', ->
  $('#gallery').masonry('destroy').infinitescroll('destroy')

