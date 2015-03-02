GALLERY_SELECTOR = '#gallery'
GALLERY_ITEM_SELECTOR = '.gallery-item'

PAGINATION_SELECTOR = '#pagination'
NEXT_PAGE_SELECTOR = '#pagination #next_page'

initialLoad = true
columnsCount = null

setColumns = ->
  if $.device.isMedium() || $.device.isLarge()
    columnsCount = 3
  else if $.device.isSmall()
    columnsCount = 2
  else
    columnsCount = 1

initGallery = ->
  $gallery = $(GALLERY_SELECTOR)

  if $gallery.length
    prepareGallery()
    Loader.start()
    $(GALLERY_ITEM_SELECTOR, $gallery).allImagesLoaded ->
      Loader.done()
      galleryImagesLoaded()

galleryImagesLoaded = ->
  Loader.done()

  $gallery = $(GALLERY_SELECTOR).show()
  $gallery.masonry
    itemSelector: GALLERY_ITEM_SELECTOR
    columnWidth: (containerWidth) ->
      containerWidth / columnsCount
    gutter: 0
    animate: true
  $gallery.transition(opacity: 1, duration: 500)

  # Apply infinite scroller to masonry

  scrollerOptions =
    navSelector: PAGINATION_SELECTOR # selector for the paged navigation
    nextSelector: NEXT_PAGE_SELECTOR # selector for the NEXT link (to page 2)
    itemSelector: GALLERY_ITEM_SELECTOR # selector for all items you'll retrieve
    maxPage: $gallery.data('totalPages')
    loading:
      start: ->
        Loader.start()
        scroller = $gallery.data('infinitescroll')
        scroller.beginAjax(scroller.options)
      finished: ->
        # currently not used
    errorCallback: (state) ->
      Loader.done()

  $gallery.infinitescroll scrollerOptions, (html) ->
    $appendedElements = $(html).hide().css(opacity: 0)
    $appendedElements.allImagesLoaded ->
      $appendedElements.show().transition(opacity: 1, duration: 500)
      $gallery.masonry('appended', $appendedElements)
      Loader.done()

prepareGallery = ->
  setColumns()
  $(GALLERY_SELECTOR).hide().css(opacity: 0)
  $(PAGINATION_SELECTOR).hide()

$(document).ready ->
  prepareGallery()
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.length
    Loader.start()
    unless initialLoad
      $gallery.allImagesLoaded ->
        galleryImagesLoaded()

$(window).load ->
  galleryImagesLoaded()
  initialLoad = false

# $(document).ready ->
#   initGallery()

$(window).resize ->
  setColumns()
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.data('masonry')
    # reloads the wall
    $gallery.masonry('reload')

$(document).on 'page:before-unload page:receive', ->
  $gallery = $(GALLERY_SELECTOR)
  $gallery.masonry('destroy').infinitescroll('destroy')
