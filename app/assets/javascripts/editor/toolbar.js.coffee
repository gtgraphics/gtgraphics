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

  constructor: ($regions, options = {}) ->
    @$regions = $regions
    @options = jQuery.extend({}, Editor.Toolbar.defaults, options)
    @groupedControls = []
    @controls = []
    _.each @options.controls, (control) =>
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
      @$toolbar.append(controlGroup.render()) if @isRendered()
      controlGroup
    else
      control = Editor.Controls.init(control) if _.isString(control)
      control.toolbar = @
      @groupedControls.push(control)
      @controls.push(control)
      @$toolbar.append(control.render()) if @isRendered()
      control

  registerEditor: (editor) ->
    @editors.push(editor)

  render: ->
    @$toolbar ||= $('<div />', class: 'btn-toolbar').data('toolbar', @)
    @$toolbar.empty()
    _.each @groupedControls, (control) =>
      @$toolbar.append(control.render())
    @$toolbar

  isRendered: ->
    @$toolbar? and @$toolbar != undefined

  destroy: ->
    @$toolbar.remove() if @$toolbar
    @$toolbar = null