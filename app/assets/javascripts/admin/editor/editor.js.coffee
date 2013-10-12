class @Editor
  constructor: ($originalInput) ->
    @input = $originalInput.hide() # $('<input />', type: 'hidden', id: inputId, name: $originalInput.attr('name'), value: $originalInput.val())
    inputId = @input.attr('id')

    @element = $('<div />', contenteditable: true, class: 'editor-region')
    @element.attr('data-target', "##{inputId}") if inputId
    @element.html($originalInput.val())

    containerClasses = $.trim("editor-container #{@input.attr('class')}")

    $container = $('<div />', class: containerClasses)
    $container.insertAfter(@input)
    $container.append(@controls())
    $container.append(@input)
    $container.append(@element)

    @input.addClass('editor-html')

    # Events
    @applyEvents()

    # Change Management
    @setUnchanged()

  controls: ->
    $controls = $('<div />', class: 'editor-controls')
    #$controls

    $('<button />', type: 'button', 'data-command': 'bold').html('<b>Bold</b>').appendTo($controls)
    $('<button />', type: 'button', 'data-command': 'italic').html('<i>Italic<i/>').appendTo($controls)
    $('<button />', type: 'button', 'data-command': 'underline').html('<u>Underline</u>').appendTo($controls)
    $('<button />', type: 'button', 'data-command': 'html').html('HTML').appendTo($controls)

    _this = @
    $controls.on 'click', 'button', (event) ->
      event.preventDefault()
      command = $(@).data('command')
      _this.command(command)

    $controls

  destroy: ->
    @element.removeClass('editable-region')
    @element.removeAttr('contenteditable')

  onOpen: ->
    @element.addClass('editing')

  onClose: ->
    @element.removeClass('editing')

  command: (command) ->
    #command.execute(@)
    if command == 'html'
      if @input.is(':hidden')
        @input.show()
        @element.hide()
      else
        @input.hide()
        @element.show()
    else
      document.execCommand(command, false, null)
      @setChanged()


  applyEvents: ->
    # Change Label Behavior
    $("label[for='#{@input.attr('id')}']").click =>
      @element.focus()

    # original input
    @input.focus =>
      @element.focus()

    @input.blur =>
      @element.blur()

    # editable region
    @element.focus =>
      @onOpen()

    @element.blur =>
      @onClose()

    @element.on 'keyup paste', =>
      @setChanged()

    @input.on 'keyup paste', =>
      @changed = true
      @element.addClass('changed')
      @element.html(@input.val())

  setChanged: ->
    @changed = true
    @element.addClass('changed')
    @input.val(@element.html())

  setUnchanged: ->
    @changed = false
    @element.removeClass('changed')