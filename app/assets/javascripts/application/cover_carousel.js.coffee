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
    @$carousel = $container.carousel(pause: false)
    @carousel = @$carousel.data('bs.carousel')
    @options = _(_(options).defaults($container.data()))
               .defaults(CoverCarousel.DEFAULTS)

    @$items = @$carousel.find(CoverCarousel.ITEM_SELECTOR)
    @$currentItem = @$items.filter(".#{CoverCarousel.ACTIVE_CLASS}")
    unless @$currentItem.length
      @$currentItem = @$items.first().addClass(CoverCarousel.ACTIVE_CLASS)

    @refreshCarouselSize()
    $(window).resize =>
      @refreshCarouselSize()

    @pause()
    coverCarousel = @
    @slideTo @$currentItem, ->
      $(@).trigger('init.gtg.carousel')
      coverCarousel.cycle() if coverCarousel.options.autostart

    @addIndicatorEvents()

  cycle: ->
    clearTimeout(@transitionTimeout)
    @transitionTimeout = setTimeout =>
      @next =>
        @cycle()
    , @options.interval

  pause: ->
    clearTimeout(@transitionTimeout)
    @transitionTimeout = null
    @$carousel.carousel('pause')

  slideTo: (item, callback) ->
    $item = @extractItem(item)
    index = @extractItemIndex(item)
    $item.trigger('changing.gtg.carousel', 'slideTo', index)
    @loadItem index, =>
      @$currentItem = $item
      @transitionCarousel(index)
      $item.trigger('change.gtg.carousel', 'slideTo', index)
      callback() if callback

  next: (callback) ->
    $item = @nextItem()
    $item.trigger('changing.gtg.carousel', 'next')
    @loadItem $item, =>
      @$currentItem = $item
      @transitionCarousel('next')
      $item.trigger('change.gtg.carousel', 'next')
      callback() if callback

  prev: (callback) ->
    @$currentItem=
    $item = @prevItem()
    $item.trigger('changing.gtg.carousel', 'prev')
    @loadItem $item, =>
      @$currentItem = $item
      @transitionCarousel('prev')
      $item.trigger('change.gtg.carousel', 'prev')
      callback() if callback

  # Navigation

  extractItem: (itemOrIndex) ->
    return itemOrIndex if itemOrIndex instanceof jQuery
    $item = @$items.filter(":nth(#{itemOrIndex})")
    jQuery.error 'item index out of range' unless $item.length
    $item

  extractItemIndex: (itemOrIndex) ->
    return @$items.index(itemOrIndex) if itemOrIndex instanceof jQuery
    itemOrIndex

  nextItem: ->
    $nextItem = @$currentItem.next(CoverCarousel.ITEM_SELECTOR)
    $nextItem = @$items.first() unless $nextItem.length
    $nextItem

  prevItem: ->
    $prevItem = @$currentItem.prev(CoverCarousel.ITEM_SELECTOR)
    $prevItem = @$items.last() unless $prevItem.length
    $prevItem

  transitionCarousel: (target) ->
    @$carousel.carousel(target).carousel('pause')

  addIndicatorEvents: ->
    carouselSelector = '#' + @$carousel.attr('id')
    $indicators = $("[data-slide-to][data-target='#{carouselSelector}']")
    $indicators.on 'click', (event) =>
      event.preventDefault()
      @pause()
      $indicator = $(event.target)
      index = $indicator.data('slideTo')
      @slideTo index, =>
        @cycle()

  loadItem: (item, callback) ->
    $item = @extractItem(item)

    # Item has already been loaded
    if $item.hasClass(CoverCarousel.LOADED_CLASS)
      callback() if callback
      return $item

    # Item must be loaded first
    $item.trigger('loading.gtg.carousel')
    $item.addClass(CoverCarousel.LOADING_CLASS)

    $cover = $item.find(".#{CoverCarousel.COVER_CLASS}")
    unless $cover.length
      $cover = $('<div />', class: CoverCarousel.COVER_CLASS).prependTo($item)

    $image = $(new Image())
    imageSrc = $item.data('cover')

    loaded = (success) ->
      callback() if callback
      $item.trigger('loaded.gtg.carousel', success)
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
    $(@).data('coverCarousel').pause()

# $(document).on 'loading.gtg.carousel', ->
#   Loader.start()

# $(document).on 'loaded.gtg.carousel', ->
#   Loader.done()
