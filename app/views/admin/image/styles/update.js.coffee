
$modal = $('#modal')

<% if @image_style.errors.empty? %>

$modal.modal('hide')

tableContent = "<%= j render('admin/image/styles/table') %>"
$('#image_styles').replaceWith(tableContent)
$('#image_styles').prepare()

<% else %>

html = "<%= escape_javascript render('form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>