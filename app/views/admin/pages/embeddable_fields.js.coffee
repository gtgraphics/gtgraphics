$embeddableManager = $('.embeddable-manager')

$pageFields = $('.page-fields', $embeddableManager)
$pageTranslations = $('.translations', $pageFields)

$embeddableFields = $('.embeddable-fields', $embeddableManager)
$embeddableTranslations = $('.translations', $embeddableFields)

<%= nested_form_content_for @page do |fields| %>
$('<%= j render("admin/pages/embeddable_fields", fields: fields) %>')
<% end %>