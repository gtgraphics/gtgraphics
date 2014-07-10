$('#modal').remove()
$('body').append("<%= escape_javascript(render(file: 'admin/images/assign_owner', layout: 'layouts/modal', formats: [:html])) %>")
$('#modal').modal('show')
$(document).click() # fix to hide dropdown menu