class @Editor.Controls.OrderedList extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'ordered_list'
    @icon = 'list-ol'
    @command = 'insertorderedlist'
    super

@Editor.Controls.register('ordered_list', @Editor.Controls.OrderedList)