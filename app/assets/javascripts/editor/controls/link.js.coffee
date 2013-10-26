class @Editor.Controls.Link extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = 'link'
    @command = 'createlink'
    @isRichTextControl = false
    super

  execCommand: ->
    # Open Modal, then execute callback
    document.execCommand('createlink', false, "http://stackoverflow.com/");

    #alert 'Open Modal'

@Editor.Controls.register('link', @Editor.Controls.Link)