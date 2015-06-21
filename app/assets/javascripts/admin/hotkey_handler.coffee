$(document).on 'hotkey', (event) ->
  if $('#modal:visible').length
    event.preventDefault()
  else
    $(event.target).click()
