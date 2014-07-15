<% if @image_style.errors.empty? %>

$('#modal').modal('hide')

tableContent = "<%= j render('admin/image/styles/table') %>"
$('#image_styles').replaceWith(tableContent)
$('#image_styles').prepare()

<% else %>

alert 'There has been an error!'

<% end %>