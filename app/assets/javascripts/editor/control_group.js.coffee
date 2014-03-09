class @Editor.Controls.ControlGroup
  constructor: (controls) ->
    @controls = controls || []

  addControl: (control) ->
    control = Editor.Controls.init(control) if _.isString(control)
    @controls.push(control)
    control

  render: ->
    $group = $('<div />', class: 'btn-group')
    $group.data('controlGroup', @)
    _.each @controls, (control) =>
      $group.append(control.render())
    $group
