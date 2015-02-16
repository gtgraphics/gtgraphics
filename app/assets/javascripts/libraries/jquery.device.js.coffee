jQuery.device =
  getSize: ->
    detector = window.getComputedStyle($('body').get(0), ':before')
    size = detector.getPropertyValue('content')
    if size.length == 4
      size.slice(1, 3)
    else
      size

  isExtraSmall: ->
    @getSize() == 'xs'

  isSmall: ->
    @getSize() == 'sm'

  isMedium: ->
    @getSize() == 'md'

  isLarge: ->
    @getSize() == 'lg'
