class CoverCarousel
  @ITEM_SELECTOR = '.item'
  @ACTIVE_CLASS = 'active'
  @LOADED_CLASS = 'loaded'
  @LOADING_CLASS = 'loading'
  @COVER_CLASS = 'cover'
  @DEFAULTS =
    interval: 5000
    autostart: true

  constructor: ($container, options = {}) ->
    @$carousel = $container
    @options = _(_(options).defaults($container.data()))
               .defaults(CoverCarousel.DEFAULTS)

    @$items = @$carousel.find(CoverCarousel.ITEM_SELECTOR)
    @$currentItem = @$items.filter(".#{CoverCarousel.ACTIVE_CLASS}")
    @$currentItem = @$items.first() unless @$currentItem.length

    @refreshCarouselSize()
    @applyCarouselResizerEvent()

    @pause()
    _this = @
    @slideTo @$currentItem, ->
      $(@).trigger('init.gtg.carousel')
      _this.start() if _this.options.autostart

    @applyIndicatorEvents()

  destroy: ->
    @pause()
    $(document).off 'click', @getIndicatorSelector(), @indicatorEventHandler
    $(window).off 'resize', @resizeEventHandler

  start: ->
    @pause()
    @transitionTimeout = setTimeout =>
      @next =>
        @start()
    , @options.interval
    @isRunning = true

  pause: ->
    clearTimeout(@transitionTimeout)
    @transitionTimeout = null
    @isRunning = false

  stop: ->
    @pause()
    @slideTo(0)

  slideTo: (item, callback) ->
    $item = @extractItem(item)
    index = @extractItemIndex(item)
    $item.trigger('changing.gtg.carousel', index)
    @loadItem index, =>
      @$currentItem = $item
      # @transitionCarousel(index)

      # Set classes
      @$items.removeClass('active next prev')
      $item.addClass('active')
      @prevItem().addClass('prev')
      @nextItem().addClass('next')

      $item.trigger('change.gtg.carousel', index)
      callback() if callback

  next: (callback) ->
    @slideTo(@nextItem(), callback)

  prev: (callback) ->
    @slideTo(@prevItem(), callback)

  # Navigation

  extractItem: (itemOrIndex) ->
    return itemOrIndex if itemOrIndex instanceof jQuery
    $item = @$items.filter(":nth(#{itemOrIndex})")
    jQuery.error 'item index out of range' unless $item.length
    $item

  extractItemIndex: (itemOrIndex) ->
    return @$items.index(itemOrIndex) if itemOrIndex instanceof jQuery
    itemOrIndex

  nextItem: ($item = @$currentItem) ->
    $nextItem = $item.next(CoverCarousel.ITEM_SELECTOR)
    $nextItem = @$items.first() unless $nextItem.length
    $nextItem

  prevItem: ($item = @$currentItem) ->
    $prevItem = $item.prev(CoverCarousel.ITEM_SELECTOR)
    $prevItem = @$items.last() unless $prevItem.length
    $prevItem

  getIndicatorSelector: ->
    carouselSelector = '#' + @$carousel.attr('id')
    "[data-slide-to][data-target='#{carouselSelector}']"

  applyIndicatorEvents: ->
    @indicatorEventHandler = =>
      event.preventDefault()
      @pause()
      $indicator = $(event.target)
      index = $indicator.data('slideTo')
      @slideTo index, =>
        @start()
    $(document).on 'click', @getIndicatorSelector(), @indicatorEventHandler

  applyCarouselResizerEvent: ->
    @resizeEventHandler = =>
      @refreshCarouselSize()
    $(window).resize(@resizeEventHandler)

  loadItem: (item, callback) ->
    $item = @extractItem(item)
    index = @extractItemIndex(item)

    # Item has already been loaded
    if $item.hasClass(CoverCarousel.LOADED_CLASS)
      callback() if callback
      return $item

    # Item must be loaded first
    $item.trigger('loading.gtg.carousel', item: $item, index: index)
    $item.addClass(CoverCarousel.LOADING_CLASS)

    $cover = $item.find(".#{CoverCarousel.COVER_CLASS}")
    unless $cover.length
      $cover = $('<div />', class: CoverCarousel.COVER_CLASS).prependTo($item)

    $image = $(new Image())
    imageSrc = $item.data('cover')

    loaded = (success) ->
      callback() if callback
      $item.trigger('loaded.gtg.carousel',
        success: success, item: $item, index: index)
      $item.removeClass(CoverCarousel.LOADING_CLASS)
      $item.addClass(CoverCarousel.LOADED_CLASS)
      $image.remove()

    $image.load ->
      $cover.css(backgroundImage: "url(#{imageSrc})")
      loaded(true)
    $image.error ->
      loaded(false)

    $image.attr('src', imageSrc) # trigger the load events

    $item

  refreshCarouselSize: ->
    $win = $(window)
    dimensions =
      width: $win.outerWidth()
      height: $win.outerHeight()
    @$carousel.css(dimensions)
    @$carousel.find('.item').css(dimensions)


$(document).ready ->
  $('[data-ride="coverCarousel"]').each ->
    $carousel = $(@)
    carousel = new CoverCarousel($carousel)
    $carousel.data('coverCarousel', carousel)
    window.coverCarousel = carousel

$(document).on 'page:receive', ->
  $carousels = $('[data-ride="coverCarousel"]')
  $carousels.each ->
    $(@).data('coverCarousel').destroy()

$(document).on 'loading.gtg.carousel', (event, context) ->
  Loader.start() if context.index == 0

$(document).on 'loaded.gtg.carousel', (event, context) ->
  Loader.done() if context.index == 0

$(window).resize ->
  $('[data-ride="coverCarousel"]').each ->
    carousel = $(@).data('coverCarousel')
    return unless carousel
    if $.device.isExtraSmall()
      carousel.stop() if carousel.isRunning
    else
      carousel.start() unless carousel.isRunning

