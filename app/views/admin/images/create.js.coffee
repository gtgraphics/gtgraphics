$modal = $('#modal')

<% if @image.errors.empty? %>

$modal.modal('hide')
Turbolinks.visit('<%= edit_admin_image_path(@image) %>')

<% else %>

html = "<%= escape_javascript render('new_form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>