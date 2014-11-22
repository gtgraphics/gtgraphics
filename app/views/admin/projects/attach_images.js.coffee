<% if @project_image_assignment_activity.errors.empty? %>

$.hideModal()
Turbolinks.visit('<%= admin_project_path(@project) %>')

<% else %>

$.updateModalForm("<%= escape_javascript render('assign_images_form') %>")

<% end %>