class @Editor.Toolbar
  constructor: (configuration) ->
    @configuration = configuration || []
    @groupedControls = []
    @controls = []
    _.each @configuration, (control) =>
      @addControl(control)

  addControl: (control) ->
    # TODO Add Control to rendered toolbar
    if _.isArray(control)
      controlGroup = new Editor.ControlGroup()
      _.each control, (nestedControl) =>
        nestedControl = Editor.Controls.init(nestedControl) if _.isString(nestedControl)
        controlGroup.addControl(nestedControl)
        @controls.push(nestedControl)        
      @groupedControls.push(controlGroup)
      controlGroup
    else
      control = Editor.Controls.init(control) if _.isString(control)
      @groupedControls.push(control)
      @controls.push(nestedControl)
      control

  render: ->
    @renderedToolbar ||= $('<div />', class: 'editor-controls').data('toolbar', @)
    $toolbar = $('<div />', class: 'btn-toolbar')
    _.each @groupedControls, (control) =>
      $toolbar.append(control.render())
    @renderedToolbar.html($toolbar)
    @renderedToolbar

  destroy: ->
    @renderedToolbar.remove() if @renderedToolbar
    @renderedToolbar = null