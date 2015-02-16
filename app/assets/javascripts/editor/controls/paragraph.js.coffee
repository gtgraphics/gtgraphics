class @Editor.Control.Paragraph extends @Editor.Control.ButtonControl
  ELEMENT_SELECTOR = 'h1, h2, h3, h4, h5, h6'

  createControl: ->
    $buttonGroup = $('<div />', class: 'btn-group')

    $button = super.appendTo($buttonGroup)
    $button.addClass('dropdown-toggle')
    $button.attr('data-toggle', 'dropdown')
    $button.append($('<b />', class: 'caret'))
    @$button = $button

    $dropdown = $('<ul />', class: 'dropdown-menu').appendTo($buttonGroup)
    @createDropdownListItem('default').appendTo($dropdown)
    _(ELEMENT_SELECTOR.split(', ')).each (tag) =>
      @createDropdownListItem(tag).appendTo($dropdown)

    $buttonGroup

  getControl: ->
    @$button

  onCreateControl: ->
    @refreshControlState()

  getCaption: ->
    I18n.translate('javascript.editor.paragraph')

  getIcon: ->
    'header'

  queryActive: ->
    $element = @getElementFromSelection()
    $element? && $element.length

  queryEnabled: ->
    @getActiveEditor()?

  querySupported: ->
    true

  getEditor: ->
    # @toolbar.activeEditor does not work here, because it may not be set yet
    _(@toolbar.editors).first()

  refreshControlState: ->
    super
    @queryDropdownItemStates()
    true

  queryDropdownItemStates: ->
    editor = @getEditor()
    if editor? && editor.options?
      control = @
      viewMode = editor.options.viewMode
      $dropdown = @$control.find('.dropdown-menu')
      $items = $dropdown.find('li').removeClass('active')
      $items.filter(->
        tag = $(@).data('paragraph')
        return false if tag == 'default'
        control.hasSelectedHeadlineWithSize(tag)
      ).addClass('active')
      $items.first().addClass('active') unless $items.filter('.active').length

  createDropdownListItem: (tag) ->
    $item = $('<li />').data('paragraph', tag)
    $link = $('<a />', href: '#').appendTo($item)
    $link.text(I18n.translate("javascript.editor.paragraphs.#{tag}"))
    $link.click (event) =>
      event.preventDefault()
      $element = @getElementFromSelection()
      if tag == 'default'
        $newElement = $($element.get(0).innerHTML)
        $element.replaceWith($newElement)
      else if $element.length
        $newElement = $("<#{tag} />").html($element.html())
        $element.replaceWith($newElement)
      else
        $newElement = $("<#{tag} />").html(@getEditor().getSelectedHtml())
        $element = @getEditor().getSelectedNodes()
        $element.replaceWith($newElement)
      @getEditor().refreshInputContent()
      @refreshControlState()
    $item

  getElementFromSelection: ->
    editor = @getActiveEditor()
    if editor
      editor.getAnchorNode().closest(ELEMENT_SELECTOR)
    else
      jQuery()

  hasSelectedHeadlineWithSize: (tag) ->
    @getElementFromSelection().is(tag)

@Editor.Control.register('paragraph', @Editor.Control.Paragraph)
