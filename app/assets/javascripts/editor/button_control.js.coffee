class Editor.Controls.ButtonControl extends Editor.Controls.Control
  createControl: ->
    $button = $('<button />', type: 'button', class: 'btn btn-default btn-sm', tabindex: '-1')
    $button.attr('title', @getCaption())
    $button.html($('<i />', class: "fa fa-#{@getIcon()}"))
    $button.tooltip(placement: 'top', container: 'body')
    $button.click =>
      $button.tooltip('hide') # fix
      @executeCommand =>
        @refresh()
    $button

  getCaption: ->
    jQuery.error 'no caption defined for control'

  getIcon: ->
    jQuery.error 'no icon defined for control'

  updateControlState: ->
    @renderedControl.prop('disabled', @disabled)
    if @active
      @renderedControl.addClass('active')
    else
      @renderedControl.removeClass('active')