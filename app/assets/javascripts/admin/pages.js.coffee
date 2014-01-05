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
        $path = $('<span />', class: 'help-block path-preview').insertAfter($slug).prepare() if $path.length == 0
        $path.text(path)

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
        $embeddableSettings.html(html).show().prepare()
      error: ->
        $embeddableType.val('').change()

loadEmbeddableEditor = ($embeddableFields, $embeddableSettings, $pageSettings, buildEmbeddable = false) ->
  $embeddableType = $pageSettings.find('#page_embeddable_type')
  $embeddableId = $embeddableSettings.find('#page_embeddable_id')

  embeddableType = $embeddableType.val()
  embeddableId = $embeddableId.val()

  $empty = $('#page_embeddable_fields_empty')
  $embeddableFields.trigger('loading.embeddable')
  if embeddableType is ''
    $empty.show()
    $embeddableFields.empty()
    $embeddableFields.trigger('empty.embeddable')
    $embeddableFields.trigger('loaded.embeddable', true)
  else
    $empty.hide()
    $embeddableFields.hide()
    $loader = $('#page_embeddable_fields_loader').show()

    data = { embeddable_type: embeddableType }
    data.embeddable_id = embeddableId unless buildEmbeddable

    jQuery.ajax
      url: '/admin/pages/embeddable_fields'
      data: data
      dataType: 'html'
      success: (html) ->
        $embeddableFields.html(html).show().prepare()
        $loader.hide()
        $embeddableFields.trigger('success.embeddable')
        $embeddableFields.trigger('loaded.embeddable', true)
      error: ->
        $embeddableFields.show()
        $embeddableType.val('').change()
        $loader.hide()
        alert(I18n.translate('pages.embeddable.error'))
        $embeddableFields.trigger('fail.embeddable')
        $embeddableFields.trigger('loaded.embeddable', false)


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
  $pageSettings = $('#page_settings')
  $embeddableSettings = $('#page_embeddable_settings')
  $embeddableFields = $('#page_embeddable_fields')

  if $embeddableFields.length > 0 and jQuery.trim($embeddableFields.html()) is ''
    loadEmbeddableEditor($embeddableFields, $embeddableSettings, $pageSettings) 

  $pageSettings
    .on 'change', '#page_embeddable_type', ->
      loadEmbeddableEditor($embeddableFields, $embeddableSettings, $pageSettings, true)    
      loadEmbeddableSettings($embeddableFields, $embeddableSettings, $pageSettings)
    .on 'change', '#page_embeddable_id', ->
      loadEmbeddableEditor($embeddableFields, $embeddableSettings, $pageSettings)