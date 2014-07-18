tableContent = "<%= j render('admin/image/styles/table') %>"
$('#image_styles').replaceWith(tableContent)
$('#image_styles').prepare().find('tr:last').hide().fadeIn('fast')