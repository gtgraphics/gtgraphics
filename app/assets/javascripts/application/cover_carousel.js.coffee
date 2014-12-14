class CoverCarousel
  constructor: ($container, options = {}) ->
    @$carousel = $container.carousel(options)
    @carousel = @$carousel.data('bs.carousel')

    @$items = @$carousel.find('.item')
    @$active = @$items.filter('.active')
    @$active = @$items.first().addClass('active') unless @$active.length

    @updateCarouselSize()
    $(window).resize =>
      @updateCarouselSize()

    @pause()
    @slideTo(@$active)

  cycle: ->
    # TODO

  pause: ->
    clearTimeout(@transitionTimeout)
    @$carousel.carousel('pause')

  slideTo: (item) ->
    index = @extractItemIndex(item)
    @loadItem index, =>
      @$carousel.carousel(index)
      @$carousel.carousel('pause')

  next: ->
    @loadItem @nextItem(), =>
      @$carousel.carousel('next')
      @$carousel.carousel('pause')

  prev: ->
    @loadItem @prevItem(), =>
      @$carousel.carousel('prev')
      @$carousel.carousel('pause')


  # Navigation

  nextItem: ->
    $nextItem = @$active.next('.item')
    $nextItem = @$items.first() unless $nextItem.length
    $nextItem

  prevItem: ->
    $prevItem = @$active.prev('.item')
    $prevItem = @$items.last() unless $prevItem.length
    $prevItem


  # Helpers

  extractItem: (itemOrIndex) ->
    if itemOrIndex instanceof jQuery
      itemOrIndex
    else
      $item = @$items.filter(":nth(#{itemOrIndex})")
      jQuery.error 'item index out of range' unless $item.length
      $item

  extractItemIndex: (itemOrIndex) ->
    if itemOrIndex instanceof jQuery
      @$items.index(itemOrIndex)
    else
      itemOrIndex

  transitionTo: (item) ->
    index = @extractItemIndex(item)
    @$carousel.carousel(index)
    @$carousel.carousel('pause')

  loadItem: (item, callback) ->
    $item = @extractItem(item)
    
    $item.trigger('transitioning.gtg.carousel')

    if $item.hasClass('loaded')
      callback() if callback()
      $item.trigger('transition.gtg.carousel')
    else
      imageSrc = $item.data('cover')

      $item.trigger('loading.gtg.carousel').addClass('loading')

      $image = $(new Image())

      $image.load -> 
        $item.removeClass('loading').addClass('loaded')
        $item.trigger('loaded.gtg.carousel', true)
        $item.css(backgroundImage: "url(#{imageSrc})")
        callback() if callback
        $item.trigger('transition.gtg.carousel')
        $image.remove()
      $image.error ->
        $item.removeClass('loading').addClass('loaded')
        $item.trigger('loaded.gtg.carousel', false)
        callback() if callback
        $item.trigger('transition.gtg.carousel')
        $image.remove()

      $image.attr('src', imageSrc) # trigger the load events

    $item

  updateCarouselSize: ->
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

    console.log carousel
    window.carousel = carousel
