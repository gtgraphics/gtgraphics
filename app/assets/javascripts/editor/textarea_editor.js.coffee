class @TextareaEditor extends @Editor
  @defaults =
    viewMode: 'richText'

  # Refreshers

  constructor: ($input, options = {}) ->
    jQuery.error 'input must be a textarea' unless $input.is('textarea')
    @$input = $input.addClass('editor-html')

    @options = jQuery.extend({}, TextareaEditor.defaults, options)
    @options.controls ||= Editor.Toolbar.defaults.controls
    
    # Get or create toolbar of this Editor (this is only the toolbar class not the rendered one)




    @refreshInternalState()

  render: ->
    unless @isRendered()
      inputId = @$input.attr('id')

      # First render region
      @$region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
      @$region.attr('data-target', "##{inputId}") if inputId
      @$region.html(@$input.val())

      # Then a toolbar can be appended to the region
      @toolbar = @options.toolbar
      @toolbar ||= new Editor.Toolbar(@$region)

      # Finally, wrap all elements with a container
      @$editor = $('<div />', class: 'editor-container')
      @$editor.insertAfter(@$input)

      # Preserve original input as HTML container
      $toolbarWrapper = $('<div />', class: 'editor-controls')
      @toolbar.render().appendTo($toolbarWrapper)
      @$editor.append($toolbarWrapper)
      @$editor.append(@$region)
      @$editor.append(@$input)

    console.log @$editor

    @refreshInputState()
    @refreshControlStates() 
    @updateViewModeState(@options.viewMode)

    @$editor

  isRendered: ->
    @$editor? and @$editor != undefined

  destroy: ->
    @$editor.remove() if @isRendered()
    @$editor = null
    @$region = null # Region DOM element should have been destroyed with the editor
    @toolbar = null # Do not delete the toolbar DOM elements
    true

  # Refreshers

  refresh: ->
    @refreshInternalState()
    if @isRendered()
      @refreshInputState()
      @refreshControlStates()
    true

  # Getters

  getToolbar: ->

    

  getRegion: ->
    @$region ||= @createRegion()

  getControls: ->
    @toolbar.controls

  # Callbacks

  refreshInternalState: ->
    @disabled = @$input.prop('disabled')

  refreshInputState: ->
    @$editor.prop('disabled', @disabled)

  refreshControlStates: ->
    if @isRendered()
      controls = @getControls()
      _.each controls, (control) ->
        control.refresh()
      true
    else
      false

  createEditor: ->
    $editor = $('<div />', class: 'editor-container')
    $editor.insertAfter(@$input)
    $editor.append(@$input)

    $region = @getRegion()
    $editor.append($region)

    $toolbar = @getToolbar()
    $editor.append($('<div />', class: 'editor-controls').html($toolbar))
    


    # change region when input is changed
    @$input.on 'textchange', =>
      @refreshRegionContent()

    $region.on 'click keyup paste', =>
      @refreshInputContent()

    $editor.on 'editor:performedAction', (event, control) =>
      if control instanceof Editor.Controls.ButtonControl
        @refreshInputContent()
        $region.focus().triggerHandler('focus')

    $editor

  createToolbar: ->
    toolbar = new Editor.Toolbar(@$region, @options.controls)
    toolbar.editor = @ # the created toolbar is bound to this editor
    toolbar.render()

  createRegion: ->
    inputId = @$input.attr('id')

    $region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
    $region.attr('data-target', "##{inputId}") if inputId
    $region.html(@$input.val())

    $region.click =>
      $region.triggerHandler('focus')
    $region.focus =>
      @onOpen()
    $region.blur =>
      @onClose()      
    $region.on 'click', 'a', (event) =>
      # Prevent links from being clicked in editor mode
      event.preventDefault() if @options.viewMode == 'richText'
    $('*', $region).focus =>
      @onOpen()

    # update states of all controls
    $region.on 'keyup focus blur', =>
      @refreshControlStates()

    @$input.on 'keyup focus blur', =>
      @refreshControlStates()

    # redirect focus to region
    @$input.on 'click focus', (event) =>
      if @options.viewMode == 'richText'
        event.preventDefault()
        $region.focus().triggerHandler('focus')

    @$input.blur (event) =>
      if @options.viewMode == 'richText'
        event.preventDefault()
        $region.blur().triggerHandler('blur')

    $region

  refreshRegionContent: ->
    @$region.html(@$input.val())

  refreshInputContent: ->
    @$input.val(@$region.html())

  onOpen: ->
    @$region.addClass('editing')
    @$editor.addClass('focus')
    @$input.trigger('editor:opened', @)

  onClose: ->
    @$region.removeClass('editing')
    @$editor.removeClass('focus')
    @$input.trigger('editor:closed', @)

  enable: ->
    @disabled = false
    @$input.prop('disabled', false)
    if @$region
      @$region.removeClass('disabled')
      @$region.attr('contenteditable', true)
    @$input.trigger('editor:enabled', @)
    true

  disable: ->
    @disabled = true
    @$input.prop('disabled', true)
    if @$region
      @$region.addClass('disabled')
      @$region.removeAttr('contenteditable')
    @$input.trigger('editor:disabled', @)
    true

  changeViewMode: (viewMode) ->
    previousViewMode = @options.viewMode
    @updateViewModeState(viewMode)
    @options.viewMode = viewMode
    @$input.focus().triggerHandler('focus') # if focus
    @$region.trigger('editor:changedView', viewMode, previousViewMode)

  updateViewModeState: (viewMode) ->
    switch viewMode
      when 'richText'
        @$input.hide()
        @$region.show()
        @$region.attr('contenteditable', true)
        @$region.attr('designmode', 'on')
        @$region.height(@$input.height())
      when 'html'
        @$input.show()
        @$region.hide()
        @$input.height(@$region.height())
      when 'preview'
        # TODO Load Preview with Interpolations (Liquid)
        #@removeSelection()
        @$input.hide()
        @$region.show()
        @$region.removeAttr('contenteditable').removeAttr('designmode')
      else
        console.error "invalid view mode: #{viewMode}"