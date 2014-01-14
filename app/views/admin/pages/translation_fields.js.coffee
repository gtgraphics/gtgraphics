$embeddableManager = $('.embeddable-manager')

$pageTranslations = $('.page-fields .translations', $embeddableManager)
$embeddableTranslations = $('.embeddable-fields .translations', $embeddableManager)


# Page Translations

<%= nested_form_content_for @page, translations: { generate_index: true } do |fields| %>
$("<%= j render('translation_fields', fields: fields) %>").appendTo($pageTranslations).prepare()
<% end %>


# Embeddable Translations

<%= nested_form_content_for @page, :embeddable, translations: { generate_index: true } do |fields| %>
$("<%= j render("admin/pages/#{@page.embeddable_class.model_name.element.pluralize}/translation_fields", fields: fields) %>").appendTo($embeddableTranslations).prepare()
<% end %>