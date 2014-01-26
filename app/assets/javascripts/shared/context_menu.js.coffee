OFFSET = 5

$(document).on 'contextmenu', '[data-context-menu]', (event) ->
  $('#context_menu').remove()

  event.preventDefault()

  $element = $(@)
  $element.trigger('opening.contextMenu')
  url = $element.data('contextMenu')

  docWidth = $(document).width()
  docHeight = $(document).height()

  console.log event.screenX

  jQuery.get url, (html) ->

    $contextMenu = $('<div />', id: 'context_menu').html(html).css(position: 'absolute', top: event.pageY + OFFSET, left: event.pageX + OFFSET)

    $('body').append($contextMenu)
    $element.trigger('opened.contextMenu')

$(document).on 'click', ->
  $('#context_menu').remove()