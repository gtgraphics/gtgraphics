GALLERY_SELECTOR = '#gallery'
GALLERY_ITEM_SELECTOR = '.gallery-item'

PAGINATION_SELECTOR = '#pagination'
NEXT_PAGE_SELECTOR = '#pagination #next_page'

initialLoad = true
columnsCount = null

setColumnsCount = ->
  if $.device.isMedium() || $.device.isLarge()
    columnsCount = 3
  else if $.device.isSmall()
    columnsCount = 2
  else
    columnsCount = 1

initialGalleryImagesLoaded = ->
  setTimeout ->
    # Wait a few milliseconds for Safari
    Loader.done()

    $('#back_to_top').show().transition(opacity: 1, duration: 500)

    $gallery = $(GALLERY_SELECTOR).show()
    $gallery.masonry
      itemSelector: GALLERY_ITEM_SELECTOR
      columnWidth: (containerWidth) ->
        containerWidth / columnsCount
      gutter: 0
      animate: true
    $gallery.transition opacity: 1, duration: 500, ->
      # Reload Masonry as not all browser recognize that it's time to get
      # ready :-(
      $gallery.masonry('reload')

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
          scroller.beginAjax(scroller.options) if scroller
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
  , 100

prepareGallery = ->
  setColumnsCount()
  $(GALLERY_SELECTOR).hide().css(opacity: 0)
  $(PAGINATION_SELECTOR).hide()

discardPageQueryParam = ->
  params = purl().param()
  if params.page
    delete params['page']
    path = purl().attr('path')
    if params.length
      url = path + '?' + jQuery.param(params)
    else
      url = path
    Turbolinks.visit(url)

$(document).ready ->
  prepareGallery()
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.length
    $('#back_to_top').hide().css(opacity: 0)
    Loader.start()
    unless initialLoad
      $gallery.allImagesLoaded ->
        initialGalleryImagesLoaded()

    discardPageQueryParam()

$(window).load ->
  initialGalleryImagesLoaded()
  initialLoad = false

$(window).resize ->
  setColumnsCount()
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.data('masonry')
    # reloads the wall
    $gallery.masonry('reload')

$(document).on 'page:before-unload page:receive', ->
  $gallery = $(GALLERY_SELECTOR)
  if $gallery.data('masonry')
    $gallery.masonry('destroy').infinitescroll('destroy')
