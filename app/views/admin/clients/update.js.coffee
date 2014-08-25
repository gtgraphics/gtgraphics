$modal = $('#modal')

<% if @client.errors.empty? %>

$modal.modal('hide')
Turbolinks.visit(document.location.href)

<% else %>

html = "<%= escape_javascript render('edit_form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>