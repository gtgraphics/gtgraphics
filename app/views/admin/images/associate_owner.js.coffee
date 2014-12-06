<% if @image_owner_assignment_form.errors.empty?%>

$.hideModal()
Turbolinks.visit('<%= admin_images_path(author_id: @image_owner_assignment_form.author) %>')

<% else %>

$.updateModalForm("<%= escape_javascript render('assign_owner_form') %>")

<% end %>