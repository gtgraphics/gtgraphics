# Add Validation Errors
$fields = Editor.active.currentModal.find('.editor-fields')
$fields.html($("<%= j render('update_failed') %>"))