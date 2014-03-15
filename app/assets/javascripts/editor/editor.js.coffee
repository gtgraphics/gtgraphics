# An Editor is for a single Region

class @Editor
  @defaults =
    viewMode: 'richText'

  constructor: ($element, options = {}) ->
    @element = $element
    @options = jQuery.extend({}, Editor.defaults, options)
    @options.controls ||= Editor.Toolbar.defaultConfig
    @viewMode = @options.viewMode
    @toolbar = @options.toolbar
    @refreshInternalState()

  render: ->
    $editor = @getEditor()
    @refreshInputState()
    @refreshControlStates() 
    @updateViewModeState(@options.viewMode)
    $editor

  isRendered: ->
    @renderedEditor? and @renderedEditor != undefined

  destroy: ->
    @renderedEditor.remove() if @isRendered()
    @renderedEditor = null
    true

  # Refreshers

  refresh: ->
    @refreshInternalState()
    if @isRendered()
      @refreshInputState()
      @refreshControlStates()
    true

  # Updates the internal state (e.g. disabled) stored as instance variable
  # within the current object
  refreshInternalState: ->
    console.warn 'refreshInternalState() has not been implemented'

  # Updates the state of the input in the DOM
  refreshInputState: ->
    console.warn 'refreshInputState() has not been implemented'

  # Updates the states of the toolbar controls in the DOM
  refreshControlStates: ->
    if @isRendered()
      controls = @getControls()
      _.each controls, (control) ->
        control.refresh()
      true
    else
      false

  # Getters

  getEditor: ->
    @renderedEditor ||= @createEditor()

  getToolbar: ->
    @toolbar ||= @createToolbar() 

  getRegion: ->
    @region ||= @createRegion()

  getControls: ->
    @getToolbar().data('toolbar').controls

  createEditor: ->
    console.warn 'createEditor() has not been implemented'

  # Callbacks

  onOpen: ->
    @element.trigger('open.editor', @)

  onClose: ->
    @element.trigger('close.editor', @)

  # Enabling/Disabling

  enable: ->
    @disabled = false
    @element.trigger('enabled.editor', @)
    true

  disable: ->
    @disabled = true
    @element.trigger('disabled.editor', @)
    true

  # View Mode

  changeViewMode: (viewMode) ->
    previousViewMode = @viewMode
    @updateViewModeState(viewMode)
    @viewMode = viewMode
    @input.focus().triggerHandler('focus') # if focus
    @region.trigger('viewModeChanged.editor', viewMode, previousViewMode)

  updateViewModeState: (viewMode) ->
    console.warn 'updateViewModeState() has not been implemented'


Editor.controls = {}