<% if @tag_assignment_activity.errors.empty?%>

$.hideModal()
Turbolinks.visit('<%= admin_images_path(tag: @tag_assignment_activity.tag_list.to_a) %>')

<% else %>

$.updateModalForm("<%= escape_javascript render('assign_tags_form') %>")

<% end %>