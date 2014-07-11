<% if @image.errors.empty? %>

$('#modal').modal('hide')
Turbolinks.visit('<%= admin_image_path(@image) %>')

<% else %>

alert 'There has been an error!'

<% end %>