<% if @shop_link.errors.empty? %>

$('#modal').modal('hide')

tableContent = "<%= j render('admin/image/shop_links/table') %>"
$('#image_shop_links').replaceWith(tableContent)
$('#image_shop_links').prepare()

<% else %>

$.updateModalForm("<%= escape_javascript render('form') %>")

<% end %>
