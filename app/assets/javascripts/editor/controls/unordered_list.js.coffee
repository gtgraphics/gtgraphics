class @Editor.Control.UnorderedList extends @Editor.Control.FontControl
  getCommand: ->
    'insertunorderedlist'

  getCaption: ->
    I18n.translate('javascript.editor.unorderedList')

  getIcon: ->
    'list-ul'

@Editor.Control.register('unorderedList', @Editor.Control.UnorderedList)