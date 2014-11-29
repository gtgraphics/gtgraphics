DRAGGABLE_SELECTOR = '[data-drag="assign"]'
DROPPABLE_SELECTOR = '[data-drop="assign"]'

$(document).ready ->

  $(DRAGGABLE_SELECTOR).disableSelection().draggable
    revert: true
    delay: 200
    helper: (event) ->
      $('<div />').text('You spin me round!')

  $(DROPPABLE_SELECTOR).droppable
    accept: DRAGGABLE_SELECTOR
    drop: (event, ui) ->
      console.log event
