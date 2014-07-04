$('#modal').remove()
$('body').append("<%= escape_javascript(render(file: 'admin/page/images/new', layout: 'layouts/modal', formats: [:html])) %>")
$('#modal').modal('show')
$(document).click() # fix to hide dropdown menu