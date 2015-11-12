$('#modal').modal('hide')

tableContent = "<%= j render('admin/image/shop_links/table') %>"
$('#image_shop_links').replaceWith(tableContent)
$('#image_shop_links').prepare()
