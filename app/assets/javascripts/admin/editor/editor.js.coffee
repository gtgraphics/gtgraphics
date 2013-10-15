class @Editor
  constructor: ($originalInput) ->
    @input = $originalInput.hide() # $('<input />', type: 'hidden', id: inputId, name: $originalInput.attr('name'), value: $originalInput.val())
    inputId = @input.attr('id')

    @element = $('<div />', contenteditable: true, class: 'editor-region')
    @element.attr('data-target', "##{inputId}") if inputId
    @element.html($originalInput.val())
    @element.css(height: @input.outerHeight())

    @container = $('<div />', class: 'editor-container')
    @container.insertAfter(@input)
    @container.append(@createControls())
    @container.append(@input)
    @container.append(@element)

    @input.addClass('editor-html')

    # Events
    @applyEvents()

    # Change Management
    @setUnchanged()

  createControls: ->
    $controls = $('<div />', class: 'editor-controls')
    #$controls

    $('<button />', type: 'button', class: 'btn btn-default btn-mini', 'data-command': 'bold').html('<i class="icon-bold"></i>').appendTo($controls)
    $('<button />', type: 'button', class: 'btn btn-default btn-mini', 'data-command': 'italic').html('<i class="icon-italic"></i>').appendTo($controls)
    $('<button />', type: 'button', class: 'btn btn-default btn-mini', 'data-command': 'underline').html('<i class="icon-underline"></i>').appendTo($controls)
    $('<button />', type: 'button', class: 'btn btn-default btn-mini', 'data-command': 'html').html('HTML').appendTo($controls)

    #document.queryCommandState('bold')

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
        @container.find('button[data-command="html"]').addClass('active')
        @element.hide()
      else
        @input.hide()
        @container.find('button[data-command="html"]').removeClass('active')
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