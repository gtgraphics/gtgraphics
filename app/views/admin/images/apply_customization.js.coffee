<% if @image.errors.empty? %>

$('#modal').modal('hide')
Turbolinks.visit('<%= admin_image_path(@image) %>')

<% else %>

alert 'Unexpected error! Please try again.'

<% end %>