tableContent = "<%= j render('admin/project/images/table') %>"
$('#project_images').replaceWith(tableContent)
$('#project_images').prepare()
