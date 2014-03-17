class @Editor.Toolbar
  @defaults = {
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
      ['orderedList', 'unorderedList', 'indent', 'outdent'],
      #['link', 'unlink'],
      #'image',
      'viewMode'
    ]
  }

  constructor: (editors, options = {}) ->
    @editors = editors
    @options = _(options).defaults(Editor.Toolbar.defaults)
    @groupedControls = []
    @controls = []
    _(@options.controls).each (control) =>
      @addControl(control)

  addControl: (control) ->
    if _(control).isArray()
      controlGroup = new Editor.ControlGroup(@)
      _(control).each (nestedControl) =>
        controlGroup.addControl(nestedControl)
      @groupedControls.push(controlGroup)
      @controls.concat(controlGroup.controls)

      @$toolbar.append(controlGroup.render()) if @isRendered()
      controlGroup
    else
      control = Editor.Controls.init(control, @) if _(control).isString()
      @groupedControls.push(control)
      @controls.push(control)
      @$toolbar.append(control.render()) if @isRendered()
      control

  render: ->
    @$toolbar ||= $('<div />', class: 'btn-toolbar').data('toolbar', @)
    @$toolbar.empty()
    _(@groupedControls).each (control) =>
      @$toolbar.append(control.render())
    @$toolbar

  isRendered: ->
    @$toolbar? and @$toolbar != undefined

  destroy: ->
    @$toolbar.remove() if @$toolbar
    @$toolbar = null
