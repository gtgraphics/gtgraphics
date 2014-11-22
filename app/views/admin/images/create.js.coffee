<% if @image.errors.empty? %>

$.hideModal()
Turbolinks.visit('<%= edit_admin_image_path(@image) %>')

<% else %>

$.updateModalForm("<%= escape_javascript render('new_form') %>")

<% end %>