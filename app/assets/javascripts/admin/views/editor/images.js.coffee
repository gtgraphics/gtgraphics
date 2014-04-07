IMAGE_ID_SELECTOR = '#editor_image_image_id'
STYLE_SELECTOR = '#editor_image_style'
SOURCE_RADIO_SELECTOR = '#editor_image_external_true, #editor_image_external_false'
STYLE_CHECKBOX_SELECTOR = '#editor_image_original_style'
IMAGE_WIDTH_SELECTOR = '#editor_image_width'
IMAGE_HEIGHT_SELECTOR = '#editor_image_height'


refreshStyles = ($scope) ->
  $image = $(IMAGE_ID_SELECTOR, $scope)
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
        $option.data('style', style)
        $option.appendTo($style)

refreshDimensions = ($scope) ->
  $image = $(IMAGE_ID_SELECTOR, $scope)
  $style = $(STYLE_SELECTOR, $scope)
  $originalStyle = $(STYLE_CHECKBOX_SELECTOR)
  $imageWidth = $(IMAGE_WIDTH_SELECTOR, $scope)
  $imageHeight = $(IMAGE_HEIGHT_SELECTOR, $scope)
  if image = $image.select2('data')
    $imageWidth.val(image.dimensions.width)
    $imageHeight.val(image.dimensions.height)
  if !$originalStyle.prop('checked') and style = $style.find('option:selected').data('style')
    $imageWidth.val(style.dimensions.width)
    $imageHeight.val(style.dimensions.height)

refreshOriginalStyleCheckboxState = ($scope) ->
  $image = $(IMAGE_ID_SELECTOR, $scope)
  $checkbox = $(STYLE_CHECKBOX_SELECTOR)
  if $image.val() == ''
    $checkbox.iCheck('disable')
  else
    image = $image.select2('data')
    if image and image.styles and image.styles.length > 0
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
  $fields = $('.editor-internal-image-styles-fields')
  if $checkbox.prop('checked')
    $fields.hide()
  else
    $fields.show()


jQuery.prepare ->
  refreshSourceContainerStates(@)
  refreshStyleContainerStates(@)
  refreshOriginalStyleCheckboxState(@)
  #refreshStyles(@)

$(document).on 'change', IMAGE_ID_SELECTOR, ->
  $select = $(@)
  image = $select.select2('data')
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

$(document).on 'show.bs.modal ajax:success', ->
  refreshSourceContainerStates()
  refreshStyleContainerStates()
  refreshStyles()
  refreshOriginalStyleCheckboxState()