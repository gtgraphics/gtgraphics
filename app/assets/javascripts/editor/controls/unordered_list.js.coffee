class @Editor.Controls.UnorderedList extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.unordered_list'))
    $button.html($('<i />', class: 'fa fa-list-ul'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('insertunorderedlist', false, null)

  queryActive: ->
    document.queryCommandState('insertunorderedlist')

  queryEnabled: ->
    document.queryCommandEnabled('insertunorderedlist')

@Editor.Controls.register('unordered_list', @Editor.Controls.UnorderedList)