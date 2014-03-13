class @Editor.Toolbar
  constructor: (configuration) ->
    @configuration = configuration || []
    @groupedControls = []
    @controls = []
    @editor = null
    _.each @configuration, (control) =>
      @addControl(control)

  addControl: (control) ->
    if _.isArray(control)
      controlGroup = new Editor.ControlGroup()
      controlGroup.toolbar = @
      _.each control, (nestedControl) =>
        nestedControl = Editor.Controls.init(nestedControl) if _.isString(nestedControl)
        nestedControl.toolbar = @
        controlGroup.addControl(nestedControl)
        @controls.push(nestedControl)        
      @groupedControls.push(controlGroup)
      @renderedToolbar.append(controlGroup.render()) if @isRendered()
      controlGroup
    else
      control = Editor.Controls.init(control) if _.isString(control)
      control.toolbar = @
      @groupedControls.push(control)
      @controls.push(control)
      @renderedToolbar.append(control.render()) if @isRendered()
      control

  render: ->
    @renderedToolbar ||= $('<div />', class: 'btn-toolbar').data('toolbar', @)
    @renderedToolbar.empty()
    _.each @groupedControls, (control) =>
      @renderedToolbar.append(control.render())
    @renderedToolbar

  isRendered: ->
    @renderedToolbar? and @renderedToolbar != undefined

  destroy: ->
    @renderedToolbar.remove() if @renderedToolbar
    @renderedToolbar = null