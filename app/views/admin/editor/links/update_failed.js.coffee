editor = $('#<%= @editor_link.target %>').data('editor')
modal = editor.currentModal
control = modal.data('owner')

# Add Validation Errors
$fields = modal.find('.editor-fields')
$fields.html($("<%= j render('update_failed') %>"))

# Trigger Control Callbacks
control.execCommandError()
control.execCommandComplete()