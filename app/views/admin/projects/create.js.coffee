$modal = $('#modal')

<% if @project.errors.empty? %>

$modal.modal('hide')
Turbolinks.visit('<%= admin_project_path(@project) %>')

<% else %>

html = "<%= escape_javascript render('new_form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>