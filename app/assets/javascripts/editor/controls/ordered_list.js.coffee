class @Editor.Controls.OrderedList extends @Editor.Controls.FontControl
  getCommand: ->
    'insertorderedlist'

  getCaption: ->
    I18n.translate('editor.orderedList')

  getIcon: ->
    'list-ol'

@Editor.Controls.register('orderedList', @Editor.Controls.OrderedList)