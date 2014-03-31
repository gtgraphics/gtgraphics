class @FormValidation.Validator.PresenceValidator
  validate: ($form, $input) ->
    deferred = new jQuery.Deferred()
    if jQuery.trim($input.val()) == ''
      $input.addValidationError(@options.message || I18n.translate('errors.messages.blank'))
      deferred.fail()
    else
      deferred.done()
    deferred.promise()

@FormValidation.registerValidator('ActiveModel::Validations::PresenceValidator', @FormValidation.Validator.PresenceValidator)
@FormValidation.registerValidator('ActiveRecord::Validations::PresenceValidator', @FormValidation.Validator.PresenceValidator)
