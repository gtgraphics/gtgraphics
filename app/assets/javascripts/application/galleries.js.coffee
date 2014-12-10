GALLERY_SELECTOR = '#gallery'
GALLERY_ITEM_SELECTOR = '.gallery-item'

PAGINATION_SELECTOR = '#pagination'
NEXT_PAGE_SELECTOR = '#pagination #next_page'


columnsCount = null

setColumns = ->
  width = window.innerWidth
  columnsCount = 1
  columnsCount = 2 if width >= 768
  columnsCount = 3 if width >= 992
  console.log width
  console.log columnsCount

$(window).resize ->
  setColumns()
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.data('masonry')
    # reloads the wall
    $gallery.masonry('reload')

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
      columnWidth: (containerWidth) ->
        containerWidth / columnsCount
      gutter: 0
      animate: true

    # Apply infinite scroller to masonry
    $gallery.infinitescroll scrollOptions, (html) ->
      $appendedElements = $(html).css(opacity: 0)
      $appendedElements.allImagesLoaded ->
        $appendedElements.animate(opacity: 1)
        $gallery.masonry 'appended', $appendedElements, ->
          NProgress.done()

$(document).on 'page:before-unload page:receive', ->
  $(GALLERY_SELECTOR).masonry('destroy').infinitescroll('destroy') 
