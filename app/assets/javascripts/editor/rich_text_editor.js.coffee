class @RichTextEditor extends @Editor
  constructor: ($originalInput, options = {}) ->
    super

  initElements: ->
    @createEditableRegion()
    @createContainer()

  createContainer: ->
    @container = $('<div />', class: 'editor-container')
    @container.insertAfter(@input)
    @container.append(@createControls())
    @container.append(@region)
    @container.append(@input)

  createEditableRegion: ->
    inputId = @input.attr('id')
    @region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
    @region.attr('data-target', "##{inputId}") if inputId
    @region.attr('spellcheck', false)
    @region.html(@input.val())