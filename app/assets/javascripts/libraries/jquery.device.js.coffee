jQuery.device =
  getSize: ->
    body = $('body').get(0)
    window.getComputedStyle(body, ':before').getPropertyValue('content')

  isExtraSmall: ->
    @getSize() == 'xs'

  isSmall: ->
    @getSize() == 'sm'

  isMedium: ->
    @getSize() == 'md'

  isLarge: ->
    @getSize() == 'lg'
