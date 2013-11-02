# Path Generator

PATH_PREVIEW_SELECTOR = '.help-block.path-preview'
PATH_PREVIEW_TYPEAHEAD_TIMEOUT = 500


previewPath = ($slug, $parentId) ->
  return if $slug.length == 0 and $parentId.length == 0
  slug = $slug.val()
  parentId = $parentId.val()
  if slug is ''
    $slug.siblings(PATH_PREVIEW_SELECTOR).remove()
  else
    jQuery.get '/admin/pages/preview_path', { slug: slug, parent_id: parentId }, (path) ->
      if path isnt ''
        $path = $slug.siblings(PATH_PREVIEW_SELECTOR)
        $path = $('<span />', class: 'help-block path-preview').insertAfter($slug) if $path.length == 0
        $path.text(path)

prepareEmbeddableContainer = ($embeddableContainer) ->
  $embeddableContainer.translationTabs()
  $embeddableContainer.find('.editor').editor()
  $embeddableContainer.find("[data-toggle=tooltip], a[rel=tooltip]").tooltip()

loadEmbeddableSettings = ($embeddableFields, $embeddableSettings, $pageSettings) ->
  $embeddableType = $pageSettings.find('#page_embeddable_type')
  embeddableType = $embeddableType.val()

  if embeddableType is ''
    $embeddableSettings.empty()
  else
    jQuery.ajax
      url: '/admin/pages/embeddable_settings'
      data: { embeddable_type: embeddableType }
      dataType: 'html'
      success: (html) ->
        $embeddableSettings.html(html).show()
      error: ->
        $embeddableType.val('').change()

loadEmbeddableEditor = ($embeddableFields, $embeddableSettings, $pageSettings) ->
  $embeddableType = $pageSettings.find('#page_embeddable_type')
  $embeddableId = $embeddableSettings.find('#page_embeddable_id')

  embeddableType = $embeddableType.val()
  embeddableId = $embeddableId.val()

  $empty = $('#page_embeddable_fields_empty')
  $embeddableFields.trigger('loading.embeddable')
  if embeddableType is ''
    $empty.show()
    $embeddableFields.empty()
    $embeddableFields.trigger('loaded.embeddable')
  else
    $empty.hide()
    $embeddableFields.hide()
    $loader = $('#page_embeddable_fields_loader').show()

    jQuery.ajax
      url: '/admin/pages/embeddable_fields'
      data: { embeddable_type: embeddableType, embeddable_id: embeddableId }
      dataType: 'html'
      success: (html) ->
        $embeddableFields.html(html).show()
        prepareEmbeddableContainer($embeddableFields)
        $loader.hide()
      error: ->
        $embeddableFields.show()
        $embeddableType.val('').change()
        $loader.hide()
        alert(I18n.translate('pages.embeddable.error'))
      complete: ->
        $embeddableFields.trigger('loaded.embeddable')

$(document).ready ->
  timeout = null

  $slug = $('#page_slug')
  $parentId = $('#page_parent_id')

  previewPath($slug, $parentId)
  
  $slug.on 'textchange', ->
    clearTimeout(timeout) if timeout
    timeout = setTimeout((=> previewPath($(@), $parentId)), PATH_PREVIEW_TYPEAHEAD_TIMEOUT)

  $slug.blur ->
    clearTimeout(timeout) if timeout
    previewPath($(@), $parentId)

  $parentId.change ->
    $slug = $('#page_slug')
    clearTimeout(timeout) if timeout
    previewPath($slug, $(@))

  # Load Embeddable Editor
  #$embeddableType = $('#page_embeddable_type')
  $pageSettings = $('#page_settings')
  $embeddableSettings = $('#page_embeddable_settings')
  $embeddableFields = $('#page_embeddable_fields')

  if $embeddableFields.length > 0

    if jQuery.trim($embeddableFields.html()) is ''
      loadEmbeddableEditor($embeddableFields, $embeddableSettings, $pageSettings) 

  $('#page_settings')
  
    .on 'change', '#page_embeddable_type', ->
      loadEmbeddableEditor($embeddableFields, $embeddableSettings, $pageSettings)    
      loadEmbeddableSettings($embeddableFields, $embeddableSettings, $pageSettings)

    .on 'change', '#page_embeddable_id', ->
      loadEmbeddableEditor($embeddableFields, $embeddableSettings, $pageSettings)
