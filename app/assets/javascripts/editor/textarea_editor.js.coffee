class @TextareaEditor extends @Editor
  constructor: ($element, options = {}) ->
    jQuery.error 'element must be a textarea' unless $element.is('textarea')
    @input = $element
    super

  # Refreshers

  refreshInternalState: ->
    @disabled = @input.prop('disabled')

  refreshInputState: ->
    @renderedEditor.prop('disabled', @disabled)

  getToolbar: ->
    @toolbar ||= @createToolbar() 

  getRegion: ->
    @region ||= @createRegion()

  getControls: ->
    toolbar = @getToolbar().data('toolbar')
    toolbar.controls

  createEditor: ->
    $editor = $('<div />', class: 'editor-container')
    $editor.insertAfter(@input)

    $toolbar = @getToolbar()
    $editor.append($toolbar)

    $region = @getRegion()
    $editor.append($region)
    
    $editor.append(@input)

    # change region when input is changed
    @input.on 'textchange', =>
      @refreshRegionContent()

    $region.on 'click keyup paste', =>
      @refreshInputContent()

    $editor.on 'executed.editor.control', (event, control) =>
      if control instanceof Editor.Controls.ButtonControl
        @refreshInputContent()

    $editor

  createToolbar: ->
    toolbar = new Editor.Toolbar(@options.controls)
    toolbar.render()

  createRegion: ->
    inputId = @input.attr('id')

    $region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
    $region.attr('data-target', "##{inputId}") if inputId
    $region.html(@input.val())

    $region.click =>
      $region.triggerHandler('focus')
    $region.focus =>
      @onOpen()
    $region.blur =>
      @onClose()      
    $region.on 'click', 'a', (event) =>
      # Prevent links from being clicked in editor mode
      event.preventDefault() if @viewMode == 'editor'
    $('*', $region).focus =>
      @onOpen()

    # update states of all controls
    $region.on 'keyup focus blur', =>
      @refreshControlStates()

    # redirect focus to region
    @input.on 'click focus', (event) =>
      if @options.viewMode == 'editor'
        event.preventDefault()
        $region.focus().triggerHandler('focus')

    @input.blur (event) =>
      if @options.viewMode == 'editor'
        event.preventDefault()
        $region.blur().triggerHandler('blur')

    $region

    # redirect label clicks from input to region
    #$("label[for='#{inputId}']").click =>
    #  @region.focus().triggerHandler('focus')

  refreshRegionContent: ->
    @region.html(@input.val())

  refreshInputContent: ->
    @input.val(@region.html())

  onOpen: ->
    super
    @region.addClass('editing')
    @renderedEditor.addClass('focus')

  onClose: ->
    super
    @region.removeClass('editing')
    #@container.removeClass('focus')
    @renderedEditor.removeClass('focus')

  enable: ->
    super
    @input.prop('disabled', false)
    if @region
      @region.removeClass('disabled')
      @region.attr('contenteditable', true)
    true

  disable: ->
    super
    @input.prop('disabled', true)
    if @region
      @region.addClass('disabled')
      @region.removeAttr('contenteditable')
    true

  updateViewModeState: (viewMode) ->
    switch viewMode
      when 'editor'
        @input.hide()
        @region.show()
        if @disabled
          @region.addClass('disabled')
        else
          @enable(false)
      when 'preview'
        #@removeSelection()
        @input.hide()
        @region.show()
        @disable(false)
        @region.removeClass('disabled')
      when 'html'
        @region.hide()
        @input.show()
        @enable(false) unless @disabled
      else
        console.error "invalid view mode: #{viewMode}"
