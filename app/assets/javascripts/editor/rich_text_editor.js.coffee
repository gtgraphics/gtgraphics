class @RichTextEditor extends @Editor
  onInit: ->
    super
    @input = @element

    @createEditableRegion()
    @createEditorContainer()

    @input.hide()
    if @input.prop('disabled')
      @disable()
    else
      @enable()

  createEditorContainer: ->
    @container = $('<div />', class: 'editor-container')
    @container.insertAfter(@input)
    @container.append(@createControls())
    @container.append(@region)
    @container.append(@input)

  createEditableRegion: ->
    inputId = @input.attr('id')
    @region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
    @region.attr('data-target', "##{inputId}") if inputId
    @region.html(@input.val())

  applyEvents: ->
    super
    inputId = @input.attr('id')
    if inputId
      $("label[for='#{inputId}']").click =>
        @region.focus().triggerHandler('focus')
