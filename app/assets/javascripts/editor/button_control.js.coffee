class @Editor.Control.ButtonControl extends @Editor.Control
  createControl: ->
    tooltipOptions = _(@toolbar.options.tooltip || {}).defaults(placement: 'top', container: 'body')
    $button = $('<button />', type: 'button', class: 'btn btn-default btn-sm', tabindex: '-1')
    $('<i />', class: "fa fa-#{@getIcon()}").appendTo($button)
    $('<span />', class: 'sr-only').text(@getCaption()).appendTo($button)
    $button.attr('title', @getCaption())
    $button.tooltip(tooltipOptions)
    $button

  onCreateControl: ->
    @$control.click =>
      @perform()

  perform: (contextData = {}) ->
    @onExecute()
    @$control.trigger('editor:command:execute', @)
    @executeCommand =>
      @refresh()
      @onExecuted()
      @$control.trigger('editor:command:executed', @)
    , contextData
    @$control.tooltip('hide') # fix for assigned tooltips

  getCaption: ->
    console.error 'no caption defined for control'

  getIcon: ->
    console.error 'no icon defined for control'

  refreshControlState: ->
    @$control.prop('disabled', @disabled)
    if @active
      @$control.addClass('active')
    else
      @$control.removeClass('active')

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