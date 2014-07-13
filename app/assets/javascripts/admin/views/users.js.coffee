refreshPasswordFieldsState = ->
  $passwordFields = $('#password_fields')
  $inputs = $passwordFields.find(':input')
  if $('[data-toggle="passwordFields"]').prop('checked')
    $passwordFields.show()
  else
    $passwordFields.hide()

refreshGeneratePasswordFieldsState = ->
  $generatePasswordFields = $('#generate_password_fields')
  $inputs = $generatePasswordFields.find(':input')
  if $('[data-toggle="generatePasswordFields"]:checked').val() == 'true'
    $generatePasswordFields.hide()
  else
    $generatePasswordFields.show()

$(document).ready ->
  refreshPasswordFieldsState()
  refreshGeneratePasswordFieldsState()

$(document).on 'change', '[data-toggle="passwordFields"]', ->
  refreshPasswordFieldsState()

$(document).on 'change', '[data-toggle="generatePasswordFields"]', ->
  refreshGeneratePasswordFieldsState()

