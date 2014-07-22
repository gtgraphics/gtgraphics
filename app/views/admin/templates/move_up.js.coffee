tableContent = "<%= j render('admin/templates/table', template_type: @template.type, checkboxes: true) %>"
$('#templates').replaceWith(tableContent)
$('#templates').prepare()
