SLUG_SELECTOR = "#page_slug"
PARENT_ID_SELECTOR = "#page_parent_id"
PATH_PREVIEW_SELECTOR = "#page_path_preview"

updatePathPreview = ->
  $slug = $(SLUG_SELECTOR)
  $parentId = $(PARENT_ID_SELECTOR)
  slug = $slug.val()
  if slug and slug isnt ""
    url = "/pages/path_preview"
    params = slug: slug
    parentId = $parentId.val()
    params.parent_id = parentId if parentId and parentId isnt ""
    $.get(url, params).done (path) ->
      $(PATH_PREVIEW_SELECTOR).text path
  else
    $(PATH_PREVIEW_SELECTOR).empty()

initPathPreview = ->
  updatePathPreview()
  $(SLUG_SELECTOR).bind "textchange", updatePathPreview
  $(PARENT_ID_SELECTOR).change updatePathPreview

$(document).ready(initPathPreview)
$(document).on('page:load', initPathPreview)