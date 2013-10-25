class @Editor.Controls.OrderedList extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.ordered_list'))
    $button.html($('<i />', class: 'fa fa-list-ol'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('insertorderedlist', false, null)

  queryActive: ->
    document.queryCommandState('insertorderedlist')

  queryEnabled: ->
    document.queryCommandEnabled('insertorderedlist')

@Editor.Controls.register('ordered_list', @Editor.Controls.OrderedList)