<% if @project.errors.empty? %>

$.hideModal()
Turbolinks.visit('<%= admin_project_path(@project) %>')

<% else %>

$.updateModalForm("<%= escape_javascript render('new_form') %>")

<% end %>