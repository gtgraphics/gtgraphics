$modal = $('#modal')

<% if @region_definition.errors.empty? %>

$modal.modal('hide')

tableContent = "<%= j render('admin/template/region_definitions/table', region_definitions: @template.region_definitions) %>"
$('#region_definitions').replaceWith(tableContent)
$('#region_definitions').prepare()

<% else %>

html = "<%= escape_javascript render('form') %>"
$('form', $modal).replaceWith(html)
$('form', $modal).prepare()

<% end %>