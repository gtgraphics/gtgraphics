class @AttachmentComboboxFormatter extends @ComboboxFormatter
  formatResult: (attachment, container, query, escapeMarkup) ->
    attachment.title

  formatSelection: (attachment) ->
    attachment.title
