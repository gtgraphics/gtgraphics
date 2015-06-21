IMAGE_ID_SELECTOR = '#editor_image_image_id'
STYLE_ID_SELECTOR = '#editor_image_style_id'
ORIGINAL_STYLE_SELECTOR = '#editor_image_original_style'
WIDTH_SELECTOR = '#editor_image_width'
HEIGHT_SELECTOR = '#editor_image_height'
INTERNAL_RADIO_SELECTOR = '#editor_image_external_false'
EXTERNAL_RADIO_SELECTOR = '#editor_image_external_true'
ALTERNATIVE_TEXT_SELECTOR = '#editor_image_alternative_text'

STYLE_FIELDS_SELECTOR = '.editor-image-style-fields'
INTERNAL_FIELDS_SELECTOR = '.editor-internal-image-fields'
EXTERNAL_FIELDS_SELECTOR = '.editor-external-image-fields'


setAlternativeText = (text) ->
  $(ALTERNATIVE_TEXT_SELECTOR).val(text) if text

setDimensions = (dimensions) ->
  $(WIDTH_SELECTOR).val(dimensions.width)
  $(HEIGHT_SELECTOR).val(dimensions.height)

refreshInternalExternalContainerState = ->
  $external = $(EXTERNAL_RADIO_SELECTOR)
  $internalFields = $(INTERNAL_FIELDS_SELECTOR)
  $externalFields = $(EXTERNAL_FIELDS_SELECTOR)
  if $external.prop('checked')
    $internalFields.hide()
    $externalFields.show()
  else
    $internalFields.show()
    $externalFields.hide()

refreshStyleContainerState = ->
  $originalStyle = $(ORIGINAL_STYLE_SELECTOR)
  $styleFields = $(STYLE_FIELDS_SELECTOR)
  $imageId = $(IMAGE_ID_SELECTOR)
  $styleId = $(STYLE_ID_SELECTOR)
  if $imageId.val()
    $originalStyle.prop('disabled', false)
    if $originalStyle.prop('checked')
      $styleFields.hide()
      $styleId.select2('enable', false)
    else
      $styleFields.show()
      $styleId.select2('enable', true)
  else
    $styleFields.hide()
    $originalStyle.prop('disabled', true)


jQuery.prepare ->
  refreshInternalExternalContainerState()
  refreshStyleContainerState()

$(document).on 'change', EXTERNAL_RADIO_SELECTOR, ->
  refreshInternalExternalContainerState()

$(document).on 'change', INTERNAL_RADIO_SELECTOR, ->
  refreshInternalExternalContainerState()

$(document).on 'change', ORIGINAL_STYLE_SELECTOR, ->
  refreshStyleContainerState()
  $originalStyle = $(@)
  image = $(IMAGE_ID_SELECTOR).select2('data')
  $styleId = $(STYLE_ID_SELECTOR)
  if $originalStyle.prop('checked')
    setAlternativeText(image.title)

$(document).on 'change', IMAGE_ID_SELECTOR, ->
  refreshStyleContainerState()
  $imageId = $(@)
  image = $imageId.select2('data')
  $styleId = $(STYLE_ID_SELECTOR)
  $styleId.data('from', image.stylesUrl)
  setDimensions(image.dimensions)
  setAlternativeText(image.title)

$(document).on 'change', STYLE_ID_SELECTOR, ->
  $styleId = $(@)
  style = $styleId.select2('data')
  setDimensions(style.dimensions)
  setAlternativeText(style.title)