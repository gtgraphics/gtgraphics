class @Editor.Toolbar
  constructor: (editor) ->
    @editor = editor
    @config = @editor.options.controls
    @controls = []

  render: ->
    $container = $('<div />', class: 'editor-controls')
    $toolbar = $('<div />', class: 'btn-toolbar').appendTo($container)
    jQuery.each @config, (index, keyOrGroup) =>
      console.log keyOrGroup
      if jQuery.isArray(keyOrGroup)
        $group = $('<div />', class: 'btn-group')
        jQuery.each keyOrGroup, (index, key) =>
          controlClass = Editor.Controls.get(key)
          if controlClass
            control = new controlClass(@editor, $group)
            @controls.push(control)
          else
            console.warn "Control not found: #{key}"
        $group.appendTo($toolbar)
      else
        controlClass = Editor.Controls.get(keyOrGroup)
        if controlClass
          control = new controlClass(@editor, $toolbar)
          @controls.push(control)
        else
          console.warn "Control not found: #{keyOrGroup}"
    $container