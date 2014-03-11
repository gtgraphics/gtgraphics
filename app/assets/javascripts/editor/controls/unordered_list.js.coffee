class @Editor.Controls.UnorderedList extends @Editor.Controls.FontControl
  getCommand: ->
    'insertunorderedlist'

  getCaption: ->
    I18n.translate('editor.unorderedList')

  getIcon: ->
    'list-ul'

@Editor.Controls.register('unorderedList', @Editor.Controls.UnorderedList)