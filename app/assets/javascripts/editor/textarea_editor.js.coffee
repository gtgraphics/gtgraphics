class @TextareaEditor extends @Editor
  constructor: ($element, options = {}) ->
    jQuery.error 'element must be a textarea' unless $element.is('textarea')
    @input = $element
    super

  # Refreshers

  refreshInternalState: ->
    @disabled = @input.prop('disabled')

  getToolbar: ->
    @toolbar ||= @createToolbar() 

  getRegion: ->
    @region ||= @createRegion()

  createEditor: ->
    $editor = $('<div />', class: 'editor-container')
    $editor.insertAfter(@input)
    $editor.append(@getToolbar())
    $editor.append(@getRegion())
    $editor.append(@input)

  createToolbar: ->
    toolbar = new Editor.Toolbar(@options.controls)
    toolbar.render()

  createRegion: ->
    inputId = @input.attr('id')
    $region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
    $region.attr('data-target', "##{inputId}") if inputId
    $region.html(@input.val())

    $region.click =>
      $region.triggerHandler('focus')
    $region.focus =>
      @onOpen()
    $region.blur =>
      @onClose()      
    $region.on 'click', 'a', (event) =>
      # Prevent links from being clicked in editor mode
      event.preventDefault() if @viewMode == 'editor'
    $('*', $region).focus =>
      @onOpen()

    # redirect focus to region
    @input.focus (event) =>
      event.preventDefault()
      $region.focus().triggerHandler('focus')

    # change region when input is changed
    @input.on 'textchange', =>
      $region.html(@input.val())

    # redirect label clicks from input to region
    $("label[for='#{inputId}']").click =>
      @region.focus().triggerHandler('focus')

  onOpen: ->
    super
    @region.addClass('editing')
    @container.addClass('focus')

  onClose: ->
    super
    @region.removeClass('editing')
    @container.removeClass('focus')

  enable: ->
    super
    @input.prop('disabled', false)
    if @region
      @region.removeClass('disabled')
      @region.attr('contenteditable', true)
    true

  disable: ->
    super
    @input.prop('disabled', true)
    if @region
      @region.addClass('disabled')
      @region.removeAttr('contenteditable')
    true

  updateViewModeState: (viewMode) ->
    switch viewMode
      when 'editor'
        @input.hide()
        @region.show()
        if @disabled
          @region.addClass('disabled')
        else
          @enable(false)
      when 'preview'
        #@removeSelection()
        @input.hide()
        @region.show()
        @disable(false)
        @region.removeClass('disabled')
      when 'html'
        @region.hide()
        @input.show()
        @enable(false) unless @disabled
      else
        console.error "invalid view mode: #{viewMode}"
