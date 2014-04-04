IMAGE_ID_SELECTOR = '#editor_image_image_id'
STYLE_ID_SELECTOR = '#editor_image_style_id'
STYLE_NAME_SELECTOR = '#editor_image_style_name'
SOURCE_RADIO_SELECTOR = '#editor_image_external_true, #editor_image_external_false'
STYLE_RADIO_SELECTOR = '#editor_image_style_source_original, #editor_image_style_source_predefined, #editor_image_style_source_custom'
IMAGE_WIDTH_SELECTOR = '#editor_image_width'
IMAGE_HEIGHT_SELECTOR = '#editor_image_height'


refreshSourceContainerStates = ($scope) ->
  $radios = $(SOURCE_RADIO_SELECTOR, $scope)
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
  $radios = $(STYLE_RADIO_SELECTOR, $scope)
  $checkedRadio = $radios.filter(':checked')
  $predefinedFields = $('.editor-internal-image-predefined-styles-fields').hide()
  $customFields = $('.editor-internal-image-custom-styles-fields').hide()
  switch $checkedRadio.val()
    when 'predefined' then $predefinedFields.show()
    when 'custom' then $customFields.show()

refreshCustomStyles = ($scope) ->
  $imageSelect = $(IMAGE_ID_SELECTOR, $scope)
  $styleSelect = $(STYLE_ID_SELECTOR, $scope)
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
  $imageSelect = $(IMAGE_ID_SELECTOR, $scope)
  $checkbox = $('#editor_image_style_source_custom')
  if $imageSelect.val() == ''
    $checkbox.iCheck('disable')
  else
    image = $imageSelect.select2('data')
    if image.customStyles and image.customStyles.length > 0
      $checkbox.iCheck('enable')
    else
      $checkbox.iCheck('disable')
      if $checkbox.prop('checked')
        $('#editor_image_style_source_original').iCheck('check')

refreshDimensions = ($scope) ->
  $imageSelect = $(IMAGE_ID_SELECTOR, $scope)
  $predefinedStyleSelect = $(STYLE_NAME_SELECTOR, $scope)
  $customStyleSelect = $(STYLE_ID_SELECTOR, $scope)
  styleSource = $(STYLE_RADIO_SELECTOR).filter(':checked').val()
  $imageWidth = $(IMAGE_WIDTH_SELECTOR, $scope).val('')
  $imageHeight = $(IMAGE_HEIGHT_SELECTOR, $scope).val('')
  switch styleSource
    when 'original'
      image = $imageSelect.select2('data')
      if image
        $imageWidth.val(image.dimensions.width)
        $imageHeight.val(image.dimensions.height)
    when 'custom'
      customStyle = $customStyleSelect.find('option:selected').data('customStyle')
      if customStyle
        $imageWidth.val(customStyle.dimensions.width)
        $imageHeight.val(customStyle.dimensions.height)


jQuery.prepare ->
  refreshSourceContainerStates(@)
  refreshStyleContainerStates(@)
  refreshCustomStyles(@)
  refreshCustomCheckboxState(@)

$(document).on 'change ifChanged', SOURCE_RADIO_SELECTOR, ->
  refreshSourceContainerStates()

$(document).on 'change ifChanged', STYLE_RADIO_SELECTOR, ->
  refreshStyleContainerStates()
  refreshDimensions()

$(document).on 'show.bs.modal ajax:success', ->
  refreshSourceContainerStates()
  refreshStyleContainerStates()
  refreshCustomStyles()
  refreshCustomCheckboxState()

$(document).on 'change', IMAGE_ID_SELECTOR, ->
  $select = $(@)
  image = $select.select2('data')
  $('#editor_image_url').val(image.assetUrl)
  $(IMAGE_WIDTH_SELECTOR).val(image.dimensions.width)
  $(IMAGE_HEIGHT_SELECTOR).val(image.dimensions.height)
  # refreshDimensions()
  $('#editor_image_alternative_text').val(image.title)
  refreshDimensions()
  refreshCustomStyles()
  refreshCustomCheckboxState()

$(document).on 'change', STYLE_ID_SELECTOR, ->
  refreshDimensions()