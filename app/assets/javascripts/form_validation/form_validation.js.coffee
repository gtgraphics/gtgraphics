class @FormValidation
  constructor: ($form) ->
    @$form = $form
    @validators = []

  validate: ->
    @validators
    #@$form.find(':input').filter('[data-validate]').each ->
    #  $input = $(@)
    #  attributeName = $input.data('validate')


availableValidators = []

_(@FormValidation).extend
  getValidator: (key) ->
    control = availableValidators[key]
    jQuery.error "Control not found: #{key}" unless control
    control

  initValidator: (key, options) ->
    klass = @getValidator(key)
    new klass(options)

  registerValidator: (key, validatorClass) ->
    availableValidators[key] = validatorClass

  unregisterValidator: (key) ->
    delete availableValidators[key]

  addError: ($input, message) ->
    $formGroup = $input.closest('.form-group').addClass('has-error')
    if message?
      $message = $formGroup.find('.help-block')
      if $message.none()
        $message = $('<span />', class: 'help-block').insertAfter($input)
        $message.hide().fadeIn('fast')
      $message.text(message)

  removeError: ($input) ->
    $formGroup = $input.closest('.form-group').removeClass('has-error')
    $message = $formGroup.find('.help-block')
    $message.remove()