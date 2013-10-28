editor = $('#<%= @editor_link.target %>').data('editor')
control = editor.currentModal.data('owner')

# Trigger Control Callbacks
control.execCommandSuccess(`<%= raw @editor_link.to_json %>`)
control.execCommandComplete()