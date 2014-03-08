class @TextareaEditor extends @Editor
  constructor: ($element, options = {}) ->
    jQuery.error 'element must be a textarea' unless $element.is('textarea')
    super

  onInit: ->
    @createToolbar()
    @createRegion()
    @createContainer()

    # carry over properties from original textarea
    @element.hide()
    if @element.prop('disabled')
      @disable()
    else
      @enable()

  getToolbar: ->
    @toolbar

  getRegion: ->
    @region

  applyEvents: ->
    super
    inputId = @element.attr('id')
    if inputId
      $("label[for='#{inputId}']").click =>
        @region.focus().triggerHandler('focus')

  createToolbar: ->
    toolbar = new Editor.Toolbar(@)
    @toolbar = toolbar.render()

  createContainer: ->
    @container = $('<div />', class: 'editor-container')
    @container.insertAfter(@element)
    @container.append(@toolbar)
    @container.append(@region)
    @container.append(@element)

  createRegion: ->
    inputId = @element.attr('id')
    @region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
    @region.attr('data-target', "##{inputId}") if inputId
    @region.html(@element.val())

  changeViewMode: (viewMode, focus = false) ->
    previousViewMode = @viewMode
    @viewMode = viewMode
    switch @viewMode
      when 'editor'
        @element.hide()
        @region.show()
        if @disabled
          @region.addClass('disabled')
        else
          @enable(false)
        @region.focus().triggerHandler('focus') if focus
      when 'preview'
        @removeSelection()
        @element.hide()
        @region.show()
        @disable(false)
        @region.removeClass('disabled')
        @region.focus().triggerHandler('focus') if focus
      when 'html'
        @region.hide()
        @element.show()
        @enable(false) unless @disabled
        @element.focus().triggerHandler('focus') if focus
      else
        return jQuery.error('invalid view mode: ' + viewMode)
    @region.trigger('viewModeChanged.editor', viewMode, previousViewMode)

  onOpen: ->
    @region.addClass('editing')
    @container.addClass('focus')

  onClose: ->
    @region.removeClass('editing')
    @container.removeClass('focus')