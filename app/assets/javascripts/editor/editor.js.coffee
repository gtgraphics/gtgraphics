# An Editor is for a single Region

class @Editor
  @defaults = {
    viewMode: 'editor',
    #controls: [
    #  ['bold', 'italic', 'underline', 'strikethrough'],
    #  ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
    #  ['orderedList', 'unorderedList', 'indent', 'outdent'],
    #  #['link', 'unlink'],
    #  #'image',
    #  'viewMode'
    #],
    controls: [['bold']]
  }

  constructor: ($element, options = {}) ->
    @element = $element
    @options = jQuery.extend({}, Editor.defaults, options)
    @refreshInternalState()
    # @changeViewMode(@options.viewMode, false)

  render: ->
    unless @renderedEditor
      $editor = @createEditor()
      $editor.data('editor', @)
      @renderedEditor = $editor
    @refreshControlState()
    @updateViewModeState(@options.viewMode)
    @renderedEditor

  destroy: ->
    @renderedEditor.remove() if @renderedEditor
    @renderedEditor = null

  # Refreshers

  refresh: ->
    @refreshInternalState()
    @refreshControlState() if @renderedEditor

  # Updates the internal state (e.g. disabled) stored as instance variable
  # within the current object
  refreshInternalState: ->
    console.warn 'refreshInternalState() has not been implemented'

  # Updates the state of the control in the DOM
  refreshControlState: ->
    console.warn 'refreshControlState() has not been implemented'

  # Getters

  getToolbar: ->
    console.warn 'no toolbar found'

  getRegion: ->
    console.warn 'no region found'

  # Callbacks

  onOpen: ->
    @element.trigger('open.editor')

  onClose: ->
    @element.trigger('close.editor')

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

  changeViewMode: (viewMode, focus = false) ->
    previousViewMode = @viewMode
    @updateViewModeState(viewMode)
    @viewMode = viewMode
    @input.focus().triggerHandler('focus') if focus
    @region.trigger('viewModeChanged.editor', viewMode, previousViewMode)

  updateViewModeState: (viewMode) ->
    console.warn 'updateViewModeState() has not been implemented'

Editor.controls = {}