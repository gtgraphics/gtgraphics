<% if @page.errors.empty? %>

$.hideModal()
Turbolinks.visit('<%= admin_page_path(@page.parent) %>')

<% else %>

$.updateModalForm("<%= escape_javascript render('new_form') %>")

<% end %>