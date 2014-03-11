class @Editor.ControlGroup
  constructor: (configuration) ->
    @configuration = configuration || []
    @controls = []
    _.each @configuration, (control) =>
      @addControl(control)

  addControl: (control) ->
    # TODO Add Control to rendered control group
    control = Editor.Controls.init(control) if _.isString(control)
    @controls.push(control)
    control

  render: ->
    @renderedGroup ||= $('<div />', class: 'btn-group').data('controlGroup', @)
    @renderedGroup.empty()
    _.each @controls, (control) =>
      @renderedGroup.append(control.render())
    @renderedGroup

  destroy: ->
    @renderedGroup.remove() if @renderedGroup
    @renderedGroup = null
    true