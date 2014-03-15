class @TextareaEditor extends @Editor
  constructor: ($element, options = {}) ->
    jQuery.error 'element must be a textarea' unless $element.is('textarea')
    @input = $element.addClass('editor-html')
    super

  # Refreshers

  refreshInternalState: ->
    @disabled = @input.prop('disabled')

  refreshInputState: ->
    @renderedEditor.prop('disabled', @disabled)

  createEditor: ->
    $editor = $('<div />', class: 'editor-container')
    $editor.insertAfter(@input)

    $toolbar = @getToolbar()
    $editor.append($('<div />', class: 'editor-controls').html($toolbar))

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
        $region.focus().triggerHandler('focus')

    $editor

  createToolbar: ->
    toolbar = new Editor.Toolbar(@options.controls)
    toolbar.editor = @ # the created toolbar is bound to this editor
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
      event.preventDefault() if @viewMode == 'richText'
    $('*', $region).focus =>
      @onOpen()

    # update states of all controls
    $region.on 'keyup focus blur', =>
      @refreshControlStates()

    @input.on 'keyup focus blur', =>
      @refreshControlStates()

    # redirect focus to region
    @input.on 'click focus', (event) =>
      if @viewMode == 'richText'
        event.preventDefault()
        $region.focus().triggerHandler('focus')

    @input.blur (event) =>
      if @viewMode == 'richText'
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
      when 'richText'
        @input.hide()
        @region.show()
        @region.attr('contenteditable', true)
        @region.attr('designmode', 'on')
        @region.height(@input.height())
      when 'html'
        @input.show()
        @region.hide()
        @input.height(@region.height())
      when 'preview'
        # TODO Load Preview with Interpolations (Liquid)
        #@removeSelection()
        @input.hide()
        @region.show()
        @region.removeAttr('contenteditable').removeAttr('designmode')
      else
        console.error "invalid view mode: #{viewMode}"
