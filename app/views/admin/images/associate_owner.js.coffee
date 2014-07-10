$modal = $('#modal')

<% if @image_owner_assignment_activity.errors.empty? %>

$modal.modal('hide')
Turbolinks.visit('<%= admin_images_path(author_id: @image_owner_assignment_activity.author) %>')

<% else %>

html = "<%= escape_javascript render('assign_owner_form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>