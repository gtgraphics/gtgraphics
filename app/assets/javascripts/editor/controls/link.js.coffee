class @Editor.Controls.Link extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = 'link'
    @command = 'createlink'
    @isRichTextControl = false
    super

  execCommand: ->
    # Open Modal, then execute callback

    @editor.storeSelection()

    console.log selection

    #alert 'Open Modal'

  initModal: ->
    # Load Modal via AJAX
    # Display modal via: $('#myModal').modal('show')
    # Restore Selection on: $(document).on 'hidden.bs.modal'

@Editor.Controls.register('link', @Editor.Controls.Link)