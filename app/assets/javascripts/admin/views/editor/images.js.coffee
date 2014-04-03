IMAGE_ID_INPUT = '#editor_image_image_id'
STYLE_ID_INPUT = '#editor_image_style_id'
SOURCE_RADIOS = '#editor_image_external_true, #editor_image_external_false'
STYLE_RADIOS = '#editor_image_style_source_original, #editor_image_style_source_predefined, #editor_image_style_source_custom'

refreshSourceContainerStates = ($scope) ->
  $radios = $(SOURCE_RADIOS, $scope)
  $checkedRadio = $radios.filter(':checked')
  $internalFields = $('.editor-internal-image-fields')
  $externalFields = $('.editor-external-image-fields')
  if $checkedRadio.val() == 'true'
    $internalFields.hide()
    $externalFields.show()
  else
    $internalFields.show()
    $externalFields.hide()

refreshStyleContainerStates = ($scope) ->
  $radios = $(STYLE_RADIOS, $scope)
  $checkedRadio = $radios.filter(':checked')
  $predefinedFields = $('.editor-internal-image-predefined-styles-fields').hide()
  $customFields = $('.editor-internal-image-custom-styles-fields').hide()
  switch $checkedRadio.val()
    when 'predefined' then $predefinedFields.show()
    when 'custom' then $customFields.show()

refreshCustomStyles = ($scope) ->
  $imageSelect = $(IMAGE_ID_INPUT, $scope)
  $styleSelect = $(STYLE_ID_INPUT, $scope)
  $styleSelect.empty()
  $('<option />', value: '').appendTo($styleSelect)
  $customCheckbox = $('#editor_image_style_source_custom')
  unless $imageSelect.val() == ''
    image = $imageSelect.select2('data')
    _(image.customStyles).each (customStyle) ->
      $option = $('<option />', value: customStyle.id).text(customStyle.caption)
      $option.data('customStyle', customStyle)
      $option.appendTo($styleSelect)

refreshCustomCheckboxState = ($scope) ->
  $inputSelect = $(IMAGE_ID_INPUT, $scope)
  image = $inputSelect.select2('data')
  $checkbox = $('#editor_image_style_source_custom')
  if image and image.customStyles.length > 0
    $checkbox.iCheck('enable')
  else
    if $checkbox.prop('checked')
      $('#editor_image_style_source_original').iCheck('check')
    $checkbox.iCheck('disable')

jQuery.prepare ->
  refreshSourceContainerStates(@)
  refreshStyleContainerStates(@)
  refreshCustomStyles(@)
  refreshCustomCheckboxState(@)

$(document).on 'change ifChanged', SOURCE_RADIOS, ->
  refreshSourceContainerStates()

$(document).on 'change ifChanged', STYLE_RADIOS, ->
  refreshStyleContainerStates()

$(document).on 'show.bs.modal ajax:success', ->
  refreshSourceContainerStates()
  refreshStyleContainerStates()
  refreshCustomStyles()
  refreshCustomCheckboxState()

$(document).on 'change', IMAGE_ID_INPUT, ->
  $select = $(@)
  image = $select.select2('data')
  $('#editor_image_url').val(image.assetUrl)
  $('#editor_image_width').val(image.dimensions.width)
  $('#editor_image_height').val(image.dimensions.height)
  # refreshDimensions()
  $('#editor_image_alternative_text').val(image.title)
  refreshDimensions()
  refreshCustomStyles()
  refreshCustomCheckboxState()

$(document).on 'change', STYLE_ID_INPUT, ->
  $select = $(@)
  # refreshDimensions()