$modal = $('#modal')

<% if @image_style.errors.empty? %>

$modal.modal('hide')

Turbolinks.visit('<%= admin_image_path(@image) %>')

jQuery.getScript("<%= customize_admin_image_style_path(@image, @image_style) %>")

<% else %>

html = "<%= escape_javascript render('form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>