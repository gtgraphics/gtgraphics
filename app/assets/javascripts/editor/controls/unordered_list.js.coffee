class @Editor.Controls.UnorderedList extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'unordered_list'
    @icon = 'list-ul'
    @command = 'insertunorderedlist'
    super

@Editor.Controls.register('unordered_list', @Editor.Controls.UnorderedList)