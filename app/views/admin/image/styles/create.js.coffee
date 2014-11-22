<% if @image_style.errors.empty? %>

$modal = $('#modal')
$modal.one 'hidden.bs.modal', ->

  tableContent = "<%= j render('admin/image/styles/table') %>"
  $('#image_styles').replaceWith(tableContent)
  $('#image_styles').prepare()

  jQuery.getScript("<%= customize_admin_image_style_path(@image, @image_style) %>")

$modal.modal('hide')

<% else %>

$.updateModalForm("<%= escape_javascript render('form') %>")

<% end %>