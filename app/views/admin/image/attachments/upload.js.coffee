tableContent = "<%= j render('admin/image/attachments/table') %>"

$container = $('#image_attachments')
$container.html(tableContent)
$container.prepare().find('tr:last').hide().fadeIn('fast')
