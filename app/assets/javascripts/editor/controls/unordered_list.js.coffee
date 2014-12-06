class @Editor.Control.UnorderedList extends @Editor.Control.FontControl
  getCommand: ->
    'insertunorderedlist'

  getCaption: ->
    I18n.translate('javascript.editor.unordered_list')

  getIcon: ->
    'list-ul'

@Editor.Control.register('unorderedList', @Editor.Control.UnorderedList)