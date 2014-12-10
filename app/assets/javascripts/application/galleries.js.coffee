GALLERY_SELECTOR = '#gallery'
GALLERY_ITEM_SELECTOR = '.gallery-item'
GALLERY_GRID_SIZING_SELECTOR = '.gallery-grid-sizer'

PAGINATION_SELECTOR = '#pagination'
NEXT_PAGE_SELECTOR = '#pagination #next_page'


columnsCount = null

setColumns = ->
  width = $(window).width()
  if width < 768 # sm
    columnsCount = 1
  else if width < 992 # md
    columnsCount = 2
  else # lg
    columnsCount = 3


$(window).resize ->
  setColumns()
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.data('masonry')
    # reloads the wall
    $gallery.masonry()

$(document).on 'page:change', ->
  setColumns()

  $gallery = $(GALLERY_SELECTOR).css(opacity: 0)

  # Prepare infinite scroller
  scrollOptions =
    navSelector: PAGINATION_SELECTOR # selector for the paged navigation
    nextSelector: NEXT_PAGE_SELECTOR # selector for the NEXT link (to page 2)
    itemSelector: GALLERY_ITEM_SELECTOR # selector for all items you'll retrieve
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
      itemSelector: GALLERY_ITEM_SELECTOR
      columnWidth: ->
        console.log $gallery.find('.gallery-grid-sizer').width()
        $gallery.find('.gallery-grid-sizer').width()
      # columnWidth: (containerWidth) ->
      #   Math.floor(containerWidth / columnsCount)
      gutter: 0
      animate: true

  # Apply infinite scroller to masonry
  $gallery.infinitescroll scrollOptions, (html) ->
    $appendedElements = $(html).css(opacity: 0)
    $appendedElements.allImagesLoaded ->
      $appendedElements.animate(opacity: 1)
      $gallery.append($appendedElements)
      $gallery.masonry 'appended', $appendedElements, ->
        NProgress.done()

$(document).on 'page:before-unload page:receive', ->
  $(GALLERY_SELECTOR).masonry('destroy').infinitescroll('destroy') 
