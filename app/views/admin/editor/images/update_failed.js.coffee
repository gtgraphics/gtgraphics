# Add Validation Errors
$modalBody = Editor.active.currentModal.find('.modal-body')
$modalBody.html($("<%= j render('update_failed') %>"))