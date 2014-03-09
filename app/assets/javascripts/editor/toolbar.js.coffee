class @Editor.Toolbar
  constructor: (config) ->
    @config = config
    @controls = []
    _.each @config, (control) =>
      @addControl(control)

  addControl: (control) ->
    if _.isArray(control)
      controlGroup = new Editor.ControlGroup()
      _.each control, (nestedControl) =>
        controlGroup.addControl(nestedControl)       
      @controls.push(controlGroup)
      controlGroup
    else
      control = Editor.Controls.init(control) if _.isString(control)
      @controls.push(control)
      control

  render: ->
    $toolbar = $('<div />', class: 'btn-toolbar editor-controls')
    _.each @controls, (control) =>
      $toolbar.append(control.render())
    $toolbar
