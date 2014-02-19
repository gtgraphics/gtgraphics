class @Editor.Controls.UnorderedList extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'unorderedList'
    @icon = 'list-ul'
    @command = 'insertunorderedlist'
    super

@Editor.Controls.register('unorderedList', @Editor.Controls.UnorderedList)