$modal = $('#modal')

<% if @page.errors.empty? %>

$modal.modal('hide')
Turbolinks.visit('<%= @location %>')

<% else %>

html = "<%= escape_javascript render('new_form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>