GALLERY_SELECTOR = '#gallery'
GALLERY_ITEM_SELECTOR = '.gallery-item'

PAGINATION_SELECTOR = '#pagination'
NEXT_PAGE_SELECTOR = '#pagination #next_page'


columnsCount = null

setColumns = ->
  if $.device.isMedium() || $.device.isLarge()
    columnsCount = 3
  else if $.device.isSmall()
    columnsCount = 2
  else
    columnsCount = 1

$(window).resize ->
  setColumns()
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.data('masonry')
    # reloads the wall
    $gallery.masonry('reload')

initGallery = ->
  $gallery = $(GALLERY_SELECTOR)

  if $gallery.length
    $gallery.hide().css(opacity: 0)

    # Determine how many gallery columns should be displayed
    setColumns()

    # Prepare infinite scroller
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

    $(scrollerOptions.navSelector).hide()

    # Image
    Loader.start()

    $(GALLERY_ITEM_SELECTOR, $gallery).allImagesLoaded ->
      setTimeout ->
        Loader.done()

        # wait a bit so all browsers are ready
        $gallery.show().transition(opacity: 1, duration: 500)
        $gallery.masonry
          itemSelector: GALLERY_ITEM_SELECTOR
          columnWidth: (containerWidth) ->
            containerWidth / columnsCount
          gutter: 0
          animate: true

        # Apply infinite scroller to masonry
        $gallery.infinitescroll scrollerOptions, (html) ->
          $appendedElements = $(html).hide().css(opacity: 0)
          $appendedElements.allImagesLoaded ->
            $appendedElements.show().transition(opacity: 1, duration: 500)
            $gallery.masonry('appended', $appendedElements)
            Loader.done()

      , 50

$(document).ready ->
  initGallery()

$(document).on 'page:before-unload page:receive', ->
  $gallery = $(GALLERY_SELECTOR)
  $gallery.masonry('destroy').infinitescroll('destroy')
