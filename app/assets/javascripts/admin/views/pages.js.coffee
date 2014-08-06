$(document).on 'change', '#page_parent_id', ->
  parentId = $(@).val()
  jQuery.getJSON "/admin/pages/#{parentId}", {}, (page) ->
    console.log page
    $('#parent_path').text("#{page.path}/")
