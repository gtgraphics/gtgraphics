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

$(document).ready ->
  timeout = null

  $slug = $('#page_slug')
  $parentId = $('#page_parent_id')
  $embeddableType = $('#page_embeddable_type')
  $embeddableContainer = $('#page_embeddable_container')

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

  $embeddableType.change ->
    embeddableType = $embeddableType.val()
    if embeddableType is ''
      $embeddableContainer.empty()
    else
      jQuery.ajax
        url: '/admin/pages/embeddable_fields'
        data: { embeddable_type: embeddableType }
        dataType: 'html'
        success: (html) ->
          $embeddableContainer.html(html).translationTabs()
          $embeddableContainer.find('.editor').editor()
          $embeddableContainer.find("[data-toggle=tooltip], a[rel=tooltip]").tooltip()
        error: ->
          alert(I18n.translate('pages.embeddable.error'))