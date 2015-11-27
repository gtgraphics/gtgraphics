$container = $('#image_downloads')
$container.html("<%= j render('admin/image/downloads/table') %>")
$container.prepare()
