$('#modal').remove()
$('body').append("<%= escape_javascript(render(file: 'admin/pages/new', layout: 'layouts/modal', formats: [:html])) %>")
$('#modal').modal('show')