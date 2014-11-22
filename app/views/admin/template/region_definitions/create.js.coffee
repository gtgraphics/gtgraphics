<% if @region_definition.errors.empty? %>

$.hideModal()

tableContent = "<%= j render('admin/template/region_definitions/table', region_definitions: @template.region_definitions) %>"
$('#region_definitions').replaceWith(tableContent)
$('#region_definitions').prepare()

<% else %>

$.updateModalForm("<%= escape_javascript render('form') %>")

<% end %>