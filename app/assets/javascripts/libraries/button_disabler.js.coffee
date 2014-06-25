AJAX_LINK_SELECTOR = 'a[data-remote=true]'
AJAX_BUTTON_SELECTOR = 'button[data-remote=true][type=button]'

createArbitraryField = ($button) ->
  $form = $button.closest('form')
  buttonName = $button.attr('name')
  buttonValue = $button.val()
  $('<input />', type: 'hidden', name: buttonName, value: buttonValue).appendTo($form)

destroyArbitraryField = ($button) ->
  $form = $button.closest('form')
  buttonName = $button.attr('name')
  $form.find("input[type='hidden'][name='#{buttonName}']").remove()

$(document)

  .on 'click', ':submit', ->
    $button = $(@)
    createArbitraryField($button)

  .on 'submit', "form:not([data-remote=true])", ->
    $(@).find(':submit').prop('disabled', true)

  .on 'ajax:beforeSend', "form[data-remote=true]", ->
    $(@).find(':submit').prop('disabled', true)

  .on 'ajax:complete', "form[data-remote=true]", ->
    $button = $(@).find(':submit')
    $button.prop('disabled', false)
    destroyArbitraryField($button)

  .on 'ajax:beforeSend', AJAX_LINK_SELECTOR, ->
    $(@).addClass('disabled')

  .on 'ajax:complete', AJAX_LINK_SELECTOR, ->
    $(@).removeClass('disabled')

  .on 'ajax:beforeSend', AJAX_BUTTON_SELECTOR, ->
    $(@).prop('disabled', true)

  .on 'ajax:complete', AJAX_BUTTON_SELECTOR, ->
    $(@).prop('disabled', false)