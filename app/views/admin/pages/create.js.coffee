<% if @page.errors.empty? %>
$('#modal').modal('hide')
Turbolinks.visit('<%= edit_admin_page_path(@page) %>')
<% else %>
$('#modal form').replaceWith("<%= escape_javascript render('new_form') %>")
<% end %>