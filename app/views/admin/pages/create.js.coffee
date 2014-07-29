$modal = $('#modal')

<% if @page.errors.empty? %>

$modal.modal('hide')
Turbolinks.visit('<%= admin_page_path(@page) %>')

<% else %>

html = "<%= escape_javascript render('new_form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>