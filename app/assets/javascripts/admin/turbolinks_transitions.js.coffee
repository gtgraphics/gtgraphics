$(document).on 'page:fetch', ->
  $('#page_content').fadeOut 100

$(document).on 'page:restore', ->
  $('#page_content').fadeIn 100