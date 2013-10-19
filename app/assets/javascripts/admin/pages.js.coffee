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
    $.get '/admin/pages/preview_path', { slug: slug, parent_id: parentId }, (path) ->
      if path isnt ''
        $path = $slug.siblings(PATH_PREVIEW_SELECTOR)
        $path = $('<span />', class: 'help-block path-preview').insertAfter($slug) if $path.length == 0
        $path.text(path)

$(document).ready ->
  timeout = null

  $slug = $('#page_slug')
  $parentId = $('#page_parent_id')

  previewPath($slug, $parentId)
  
  $slug.on 'textchange', ->
    $parentId = $('#page_parent_id')
    clearTimeout(timeout) if timeout
    timeout = setTimeout((=> previewPath($(@), $parentId)), PATH_PREVIEW_TYPEAHEAD_TIMEOUT)

  $parentId.change ->
    $slug = $('#page_slug')
    clearTimeout(timeout) if timeout
    previewPath($slug, $(@))