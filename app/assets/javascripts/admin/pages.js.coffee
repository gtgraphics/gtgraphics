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

loadEmbeddableEditor = ($embeddableContainer, $embeddableType) ->
  embeddableType = $embeddableType.val()
  $empty = $('#page_embeddable_container_empty')
  $embeddableContainer.trigger('loading.embeddable')
  if embeddableType is ''
    $empty.show()
    $embeddableContainer.empty()
    $embeddableContainer.trigger('loaded.embeddable')
  else
    $empty.hide()
    $embeddableContainer.hide()
    $loader = $('#page_embeddable_container_loader').show()
    jQuery.ajax
      url: '/admin/pages/embeddable_fields'
      data: { embeddable_type: embeddableType }
      dataType: 'html'
      success: (html) ->
        $embeddableContainer.html(html).show()
        prepareEmbeddableContainer($embeddableContainer)
        $loader.hide()
      error: ->
        $embeddableContainer.show()
        $embeddableType.val('').change()
        $loader.hide()
        alert(I18n.translate('pages.embeddable.error'))
      complete: ->
        $embeddableContainer.trigger('loaded.embeddable')


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
  $embeddableType = $('#page_embeddable_type')
  $embeddableContainer = $('#page_embeddable_container')

  if $embeddableContainer.length > 0

    if jQuery.trim($embeddableContainer.html()) is ''
      loadEmbeddableEditor($embeddableContainer, $embeddableType) 

    $embeddableType.change ->
      loadEmbeddableEditor($embeddableContainer, $embeddableType)