$container = $('#image_attachments')
$container.html("<%= j render('admin/image/attachments/table') %>")
$container.prepare()
