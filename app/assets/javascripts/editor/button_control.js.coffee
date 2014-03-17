class Editor.Control.ButtonControl extends Editor.Control
  createControl: ->
    tooltipOptions = jQuery.extend({ placement: 'top', container: 'body' }, @toolbar.options.tooltip)

    $button = $('<button />', type: 'button', class: 'btn btn-default btn-sm', tabindex: '-1')
    $button.attr('title', @getCaption())
    $button.html($('<i />', class: "fa fa-#{@getIcon()}"))
    $button.tooltip(tooltipOptions)
    $button.click =>
      $button.trigger('editor:control:execute', @)
      @executeCommand =>
        @refresh()
        $button.trigger('editor:control:executed', @)
      $button.tooltip('hide') # fix for assigned tooltips
    $button

  getCaption: ->
    console.error 'no caption defined for control'

  getIcon: ->
    console.error 'no icon defined for control'

  refreshControlState: ->
    @$control.prop('disabled', @disabled)
    if @active
      @$control.addClass('active')
    else
      @$control.removeClass('active')