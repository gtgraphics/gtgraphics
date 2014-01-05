$html = $("<%= j nested_form_content_for(@page) { |fields| render('embeddable_fields', fields: fields) } %>").filter(".tab-pane[data-locale]")

console.log $html