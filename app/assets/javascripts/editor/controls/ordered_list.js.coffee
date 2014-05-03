class @Editor.Control.OrderedList extends @Editor.Control.FontControl
  getCommand: ->
    'insertorderedlist'

  getCaption: ->
    I18n.translate('javascript.editor.orderedList')

  getIcon: ->
    'list-ol'

@Editor.Control.register('orderedList', @Editor.Control.OrderedList)