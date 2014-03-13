class @Editor.ControlGroup
  constructor: (toolbar, configuration = []) ->
    @toolbar = toolbar
    @configuration = configuration
    @controls = []
    _.each @configuration, (control) =>
      @addControl(control)

  addControl: (control) ->
    control = Editor.Controls.init(control) if _.isString(control)
    control.group = @
    control.toolbar = @toolbar
    @controls.push(control)
    @renderedGroup.append(control.render) if @isRendered()
    control

  render: ->
    @renderedGroup ||= $('<div />', class: 'btn-group').data('controlGroup', @)
    @renderedGroup.empty()
    _.each @controls, (control) =>
      @renderedGroup.append(control.render())
    @renderedGroup

  isRendered: ->
    @renderedGroup? and @renderedGroup != undefined

  destroy: ->
    @renderedGroup.remove() if @renderedGroup
    @renderedGroup = null
    true