tableContent = "<%= j render('admin/image/downloads/table') %>"

$container = $('#image_downloads')
$container.html(tableContent)
$container.prepare().find('tr:last').hide().fadeIn('fast')
