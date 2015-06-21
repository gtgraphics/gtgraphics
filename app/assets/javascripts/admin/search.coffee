# fix for Windows
$(document).on 'keydown', '.search-component .search-input', (event) ->
  if event.which == 13
    event.preventDefault()
    $input = $(@)
    $button = $input.closest('.search-component').find(':submit')
    $button.click()

