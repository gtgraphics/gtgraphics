class @Editor.Control.ButtonControl extends @Editor.Control
  createControl: ->
    tooltipOptions = _(@toolbar.options.tooltip || {}).defaults(placement: 'top', container: 'body')

    $button = $('<button />', type: 'button', class: 'btn btn-default btn-sm', tabindex: '-1')
    $icon = $('<i />', class: "fa fa-#{@getIcon()}")
    $button.html($icon).attr('title', @getCaption())
    $button.tooltip(tooltipOptions)
    $button.click =>
      $button.trigger('editor:command:execute', @)
      @executeCommand =>
        @refresh()
        $button.trigger('editor:command:executed', @)
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