class @Editor.ControlGroup
  constructor: (toolbar) ->
    @toolbar = toolbar
    @controls = []

  addControl: (control) ->
    control = Editor.Control.init(control, @toolbar) if _(control).isString()
    control.controlGroup = @
    @controls.push(control)
    @$group.append(control.render()) if @isRendered()
    control

  render: ->
    @$group ||= $('<div />', class: 'btn-group').data('controlGroup', @)
    @$group.empty()
    _(@controls).each (control) =>
      @$group.append(control.render())
    @$group

  isRendered: ->
    @$group? and @$group != undefined

  destroy: ->
    @$group.remove() if @$group
    @$group = null
    true