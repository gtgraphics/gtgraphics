class @Editor.Control.ButtonControl extends @Editor.Control
  createControl: ->
    tooltipOptions = _(@toolbar.options.tooltip || {}).defaults(placement: 'top', container: 'body')
    $button = $('<button />', type: 'button', class: 'btn btn-default', tabindex: '-1')
    $('<i />', class: "fa fa-#{@getIcon()} fa-fw").appendTo($button)
    $('<span />', class: 'sr-only').text(@getCaption()).appendTo($button)
    $button.attr('title', @getCaption())
    $button.tooltip(tooltipOptions)
    $button

  onCreateControl: ->
    @getControl().click =>
      @perform()

  perform: (contextData = {}) ->
    @onExecute()
    @getControl().trigger('editor:command:execute', @)
    @executeCommand =>
      @refresh()
      @onExecuted()
      @getControl().trigger('editor:command:executed', @)
    , contextData
    @getControl().tooltip('hide') # fix for assigned tooltips

  getCaption: ->
    console.error 'no caption defined for control'

  getIcon: ->
    console.error 'no icon defined for control'

  refreshControlState: ->
    @getControl().prop('disabled', @disabled)
    if @active
      @getControl().addClass('active')
    else
      @getControl().removeClass('active')

  onExecute: ->

  onExecuted: ->

  getRegionDocument: ->
    if @toolbar.activeEditor and @toolbar.activeEditor.isRendered()
      @toolbar.activeEditor.$regionFrame.get(0).contentDocument

  getRegionBody: ->
    regionDocument = @getRegionDocument()
    $(regionDocument).find('body') if regionDocument

  isInRichTextView: ->
    @toolbar.activeEditor and @toolbar.activeEditor.options.viewMode == 'richText'
