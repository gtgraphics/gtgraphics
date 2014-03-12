class Editor.Controls.ButtonControl extends Editor.Controls.Control
  createControl: ->
    $button = $('<button />', type: 'button', class: 'btn btn-default btn-sm', tabindex: '-1')
    $button.attr('title', @getCaption())
    $button.html($('<i />', class: "fa fa-#{@getIcon()}"))
    $button.tooltip(placement: 'top', container: 'body')
    $button.click =>
      $button.trigger('execute.editor.control', @)
      @executeCommand =>
        @refresh()
        $button.trigger('executed.editor.control', @)
      $button.tooltip('hide') # fix for assigned tooltips
    $button

  getCaption: ->
    console.error 'no caption defined for control'

  getIcon: ->
    console.error 'no icon defined for control'

  refreshControlState: ->
    @renderedControl.prop('disabled', @disabled)
    if @active
      @renderedControl.addClass('active')
    else
      @renderedControl.removeClass('active')