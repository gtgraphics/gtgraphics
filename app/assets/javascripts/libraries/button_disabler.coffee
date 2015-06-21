AJAX_LINK_SELECTOR = 'a[data-remote=true]'
AJAX_BUTTON_SELECTOR = 'button[data-remote=true][type=button]'

createArbitraryField = ($submit) ->
  $form = $submit.closest('form')
  $('<input />', type: 'hidden', name: $submit.attr('name'), value: $submit.val()).appendTo($form)

destroyArbitraryField = ($submit) ->
  $form = $submit.closest('form')
  buttonName = $submit.attr('name')
  $("input[type='hidden'][name='#{buttonName}']", $form).remove()

$(document)

  .on 'click', ':submit', ->
    $submit = $(@)
    createArbitraryField($submit)

  .on 'submit', "form:not([data-remote=true])", ->
    $(@).find(':submit').prop('disabled', true)

  .on 'ajax:beforeSend', "form[data-remote=true]", ->
    $submit = $(@).find(':submit')
    $submit.data('prevState', $submit.prop('disabled'))
    $submit.prop('disabled', true)

  .on 'ajax:complete', "form[data-remote=true]", ->
    $submit = $(@).find(':submit')
    $submit.prop('disabled', $submit.data('prevState') || false)
    $submit.removeData('prevState')
    $submit.each -> destroyArbitraryField($(@))

  .on 'ajax:beforeSend', AJAX_LINK_SELECTOR, ->
    $(@).addClass('disabled')

  .on 'ajax:complete', AJAX_LINK_SELECTOR, ->
    $(@).removeClass('disabled')

  .on 'ajax:beforeSend', AJAX_BUTTON_SELECTOR, ->
    $(@).prop('disabled', true)

  .on 'ajax:complete', AJAX_BUTTON_SELECTOR, ->
    $(@).prop('disabled', false)