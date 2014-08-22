$modal = $('#modal')

<% if @project_image_assignment_activity.errors.empty? %>

$modal.modal('hide')
Turbolinks.visit('<%= admin_project_path(@project) %>')

<% else %>

html = "<%= escape_javascript render('assign_images_form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>