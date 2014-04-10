IMAGE_ID_SELECTOR = '#editor_image_image_id'
STYLE_SELECTOR = '#editor_image_style'
SOURCE_RADIO_SELECTOR = '#editor_image_external_true, #editor_image_external_false'
STYLE_CHECKBOX_SELECTOR = '#editor_image_original_style'
IMAGE_WIDTH_SELECTOR = '#editor_image_width'
IMAGE_HEIGHT_SELECTOR = '#editor_image_height'


refreshStyles = ($scope) ->
  $image = $(IMAGE_ID_SELECTOR, $scope)
  if $image.any()
    $style = $(STYLE_SELECTOR, $scope)
    $style.empty()
    $('<option />', value: '').appendTo($style)
    imageId = $image.val()
    unless imageId == ''
      image = $image.select2('data')
      if image
        _(image.styles).each (style) ->
          if style.type == 'predefined'
            value = style.styleName
          else
            value = style.id
          $option = $('<option />', value: value).text(style.caption)
          $option.data('dimensions', style.dimensions)
          $option.appendTo($style)

refreshDimensions = ($scope) ->
  $image = $(IMAGE_ID_SELECTOR, $scope)
  $style = $(STYLE_SELECTOR, $scope)
  if $image.any() and $style.any() 
    $originalStyle = $(STYLE_CHECKBOX_SELECTOR)
    $imageWidth = $(IMAGE_WIDTH_SELECTOR, $scope)
    $imageHeight = $(IMAGE_HEIGHT_SELECTOR, $scope)

    if image = $image.select2('data')
      $imageWidth.val(image.dimensions.width)
      $imageHeight.val(image.dimensions.height)

    dimensions = dimensions = $style.find('option:selected').data('dimensions')
    if !$originalStyle.prop('checked') and dimensions
      $imageWidth.val(dimensions.width)
      $imageHeight.val(dimensions.height)

refreshOriginalStyleCheckboxState = ($scope) ->
  $image = $(IMAGE_ID_SELECTOR, $scope)
  $style = $(STYLE_SELECTOR, $scope)
  if $image.any() and $style.any()
    $checkbox = $(STYLE_CHECKBOX_SELECTOR)
    if $image.val() == ''
      $checkbox.iCheck('disable')
    else
      if $style.find('option').any()
        $checkbox.iCheck('enable')
      else
        $checkbox.iCheck('disable')
        $checkbox.iCheck('check') if $checkbox.prop('checked')

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
  $checkbox = $(STYLE_CHECKBOX_SELECTOR, $scope)
  if $checkbox.any()
    $fields = $('.editor-internal-image-styles-fields')
    if $checkbox.prop('checked')
      $fields.hide()
    else
      $fields.show()


jQuery.prepare ->
  refreshSourceContainerStates(@)
  refreshStyleContainerStates(@)
  refreshDimensions(@)

#$(document).on 'select2-init', IMAGE_ID_SELECTOR, ->
#  refreshOriginalStyleCheckboxState()
#  refreshStyleContainerStates()

$(document).on 'change', IMAGE_ID_SELECTOR, ->
  $select = $(@)
  image = $select.select2('data')
  if image
    $('#editor_image_url').val(image.assetUrl)
    $('#editor_image_alternative_text').val(image.title)
    refreshStyles()
    refreshOriginalStyleCheckboxState()
    refreshDimensions()

#$(document).on 'select2-init', IMAGE_ID_SELECTOR, ->
#  refreshStyles()
#  refreshOriginalStyleCheckboxState()

$(document).on 'change', STYLE_SELECTOR, ->
  refreshDimensions()

$(document).on 'ifChanged', SOURCE_RADIO_SELECTOR, ->
  refreshSourceContainerStates()

$(document).on 'ifChanged', STYLE_CHECKBOX_SELECTOR, ->
  refreshStyleContainerStates()
  refreshDimensions()