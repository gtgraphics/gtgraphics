class @Editor.Controls.OrderedList extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'orderedList'
    @icon = 'list-ol'
    @command = 'insertorderedlist'
    super

@Editor.Controls.register('orderedList', @Editor.Controls.OrderedList)