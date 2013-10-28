editor = $('#<%= @editor_link.target %>').data('editor')
control = editor.currentModal.data('owner')

# Trigger Control Callbacks
control.execCommandSuccess("<%= j content_tag(:a, @editor_link.caption, href: @editor_link.url, target: @editor_link.new_window? ? '_blank' : nil) %>")
control.execCommandComplete()