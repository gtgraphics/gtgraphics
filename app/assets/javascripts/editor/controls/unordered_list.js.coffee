class @Editor.Control.UnorderedList extends @Editor.Control.FontControl
  getCommand: ->
    'insertunorderedlist'

  getCaption: ->
    I18n.translate('editor.unorderedList')

  getIcon: ->
    'list-ul'

@Editor.Control.register('unorderedList', @Editor.Control.UnorderedList)