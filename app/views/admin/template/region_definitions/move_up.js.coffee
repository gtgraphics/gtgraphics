tableContent = "<%= j render('admin/template/region_definitions/table', region_definitions: @template.region_definitions) %>"
$('#region_definitions').replaceWith(tableContent)
$('#region_definitions').prepare().prepare()
