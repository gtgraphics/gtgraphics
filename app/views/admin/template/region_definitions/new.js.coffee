$('#modal').remove()
$('body').append("<%= j render(file: 'admin/template/region_definitions/new', layout: 'layouts/modal', formats: [:html]) %>")
$('#modal').modal('show')
$(document).click() # fix to hide dropdown menu