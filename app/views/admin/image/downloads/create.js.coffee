<% if @image_download_assignment_form.errors.empty? %>

$modal = $('#modal')
$modal.one 'hidden.bs.modal', ->
  $container = $('#image_downloads')
  $container.html("<%= j render('admin/image/downloads/table') %>")
  $container.prepare()

$modal.modal('hide')

<% else %>

$.updateModalForm("<%= escape_javascript render('form') %>")

<% end %>
