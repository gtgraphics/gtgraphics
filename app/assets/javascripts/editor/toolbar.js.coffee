class @Editor.Toolbar
  constructor: (configuration) ->
    @configuration = configuration || []
    @controls = []
    _.each @configuration, (control) =>
      @addControl(control)

  addControl: (control) ->
    # TODO Add Control to rendered toolbar
    if _.isArray(control)
      controlGroup = new Editor.ControlGroup()
      _.each control, (nestedControl) ->
        controlGroup.addControl(nestedControl)       
      @controls.push(controlGroup)
      controlGroup
    else
      control = Editor.Controls.init(control) if _.isString(control)
      @controls.push(control)
      control

  render: ->
    @renderedToolbar ||= $('<div />', class: 'btn-toolbar editor-controls').data('toolbar', @)
    @renderedToolbar.empty()
    _.each @controls, (control) =>
      @renderedToolbar.append(control.render())
    @renderedToolbar

  destroy: ->
    @renderedToolbar.remove() if @renderedToolbar
    @renderedToolbar = null