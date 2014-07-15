$('#modal').remove()
$('body').append("<%= escape_javascript render(file: 'admin/image/styles/edit', layout: 'layouts/modal', formats: [:html]) %>")
$('#modal').modal('show')
$(document).click() # fix to hide dropdown menu