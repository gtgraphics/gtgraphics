<% if @attachment_assignment_form.errors.empty? %>

$modal = $('#modal')
$modal.one 'hidden.bs.modal', ->
  $container = $('#image_attachments')
  $container.html("<%= j render('admin/image/attachments/table') %>")
  $container.prepare()

$modal.modal('hide')

<% else %>

$.updateModalForm("<%= escape_javascript render('form') %>")

<% end %>
