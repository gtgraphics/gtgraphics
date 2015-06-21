class @Editor.Control.ViewMode extends @Editor.Control.ButtonControl
  createControl: ->
    $buttonGroup = $('<div />', class: 'btn-group pull-right')
    $button = $('<button />', class: 'btn btn-default dropdown-toggle', type: 'button', tabindex: '-1', 'data-toggle': 'dropdown')
    $button.append($('<b />', class: 'caret')).appendTo($buttonGroup)
    $dropdown = $('<ul />', class: 'dropdown-menu').appendTo($buttonGroup)
    @createDropdownListItem('richText', I18n.translate('javascript.editor.view_modes.rich_text'), 'font').appendTo($dropdown)
    @createDropdownListItem('html', I18n.translate('javascript.editor.view_modes.html'), 'code').appendTo($dropdown)
    @createDropdownListItem('preview', I18n.translate('javascript.editor.view_modes.preview'), 'file-o').appendTo($dropdown)
    @$button = $button
    $buttonGroup

  getEditor: ->
    # @toolbar.activeEditor does not work here, because it may not be set yet
    _(@toolbar.editors).first()

  getControl: ->
    @$button

  onCreateControl: ->
    @refreshControlState()

  execCommand: ->
    # do nothing when caret button is clicked

  refreshControlState: ->
    super
    @queryDropdownItemStates()
    true

  queryDropdownItemStates: ->
    editor = @getEditor()
    if editor? && editor.options?
      viewMode = editor.options.viewMode
      $dropdown = @getControlContainer().find('.dropdown-menu')
      $buttons = $dropdown.find('li').removeClass('active')
      $buttons.filter(-> $(@).data('viewMode') == viewMode).addClass('active')

  createDropdownListItem: (viewMode, caption, icon) ->
    $item = $('<li />').data('viewMode', viewMode)
    $link = $('<a />', href: '#').appendTo($item)
    $link.html("<span class='prepend-icon'><i class='fa fa-fw fa-#{icon}'></i><span class='caption'>#{caption}</span></span>")
    $link.click (event) =>
      event.preventDefault()
      @getEditor().changeViewMode(viewMode, true)
    $item

@Editor.Control.register('viewMode', @Editor.Control.ViewMode)
