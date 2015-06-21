$(document).on 'click', '[data-submit]', (event) ->
  event.preventDefault()
  formSelector = $(@).data('submit')
  $form = $(formSelector)
  $form.submit()
