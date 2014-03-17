class @TextareaEditor
  @defaults =
    viewMode: 'richText'

  # Refreshers

  constructor: ($textarea, options = {}) ->
    jQuery.error 'input must be a textarea' unless $textarea.is('textarea')
    @$textarea = $textarea.addClass('editor-html')

    @options = jQuery.extend({}, TextareaEditor.defaults, options)
    @options.controls ||= Editor.Toolbar.defaults.controls
    
    # Get or create toolbar of this Editor (this is only the toolbar class not the rendered one)

    @refreshInternalState()

  render: ->
    unless @isRendered()
      inputId = @$textarea.attr('id')

      # First render region
      @$region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
      @$region.attr('data-target', "##{inputId}") if inputId
      @$region.html(@$textarea.val())

      # Then a toolbar can be appended to the region
      @toolbar = @options.toolbar || new Editor.Toolbar(@)

      # Finally, wrap all elements with a container
      @$editor = $('<div />', class: 'editor-container')
      @$editor.insertAfter(@$textarea)

      # Preserve original input as HTML container
      $toolbarWrapper = $('<div />', class: 'editor-controls')
      @toolbar.render().appendTo($toolbarWrapper)
      @$editor.append($toolbarWrapper)
      @$editor.append(@$region)
      @$editor.append(@$textarea)

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
    @disabled = @$textarea.prop('disabled')

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
    $editor.insertAfter(@$textarea)
    $editor.append(@$textarea)

    $region = @getRegion()
    $editor.append($region)

    $toolbar = @getToolbar()
    $editor.append($('<div />', class: 'editor-controls').html($toolbar))
    


    # change region when input is changed
    @$textarea.on 'textchange', =>
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
    inputId = @$textarea.attr('id')

    $region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
    $region.attr('data-target', "##{inputId}") if inputId
    $region.html(@$textarea.val())

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

    @$textarea.on 'keyup focus blur', =>
      @refreshControlStates()

    # redirect focus to region
    @$textarea.on 'click focus', (event) =>
      if @options.viewMode == 'richText'
        event.preventDefault()
        $region.focus().triggerHandler('focus')

    @$textarea.blur (event) =>
      if @options.viewMode == 'richText'
        event.preventDefault()
        $region.blur().triggerHandler('blur')

    $region

  refreshRegionContent: ->
    @$region.html(@$textarea.val())

  refreshInputContent: ->
    @$textarea.val(@$region.html())

  onOpen: ->
    @$region.addClass('editing')
    @$editor.addClass('focus')
    @$textarea.trigger('editor:opened', @)

  onClose: ->
    @$region.removeClass('editing')
    @$editor.removeClass('focus')
    @$textarea.trigger('editor:closed', @)

  enable: ->
    @disabled = false
    @$textarea.prop('disabled', false)
    if @$region
      @$region.removeClass('disabled')
      @$region.attr('contenteditable', true)
    @$textarea.trigger('editor:enabled', @)
    true

  disable: ->
    @disabled = true
    @$textarea.prop('disabled', true)
    if @$region
      @$region.addClass('disabled')
      @$region.removeAttr('contenteditable')
    @$textarea.trigger('editor:disabled', @)
    true

  changeViewMode: (viewMode) ->
    previousViewMode = @options.viewMode
    @updateViewModeState(viewMode)
    @options.viewMode = viewMode
    @$textarea.focus().triggerHandler('focus') # if focus
    @$region.trigger('editor:changedView', viewMode, previousViewMode)

  updateViewModeState: (viewMode) ->
    switch viewMode
      when 'richText'
        @$textarea.hide()
        @$region.show()
        @$region.attr('contenteditable', true)
        @$region.attr('designmode', 'on')
        @$region.height(@$textarea.height())
      when 'html'
        @$textarea.show()
        @$region.hide()
        @$textarea.height(@$region.height())
      when 'preview'
        # TODO Load Preview with Interpolations (Liquid)
        #@removeSelection()
        @$textarea.hide()
        @$region.show()
        @$region.removeAttr('contenteditable').removeAttr('designmode')
      else
        console.error "invalid view mode: #{viewMode}"