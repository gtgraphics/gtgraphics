class @Editor.Control.ViewMode extends @Editor.Control.ButtonControl
  createControl: ->
    $buttonGroup = $('<div />', class: 'btn-group pull-right')
    $button = $('<button />', class: 'btn btn-default btn-sm dropdown-toggle', type: 'button', tabindex: '-1', 'data-toggle': 'dropdown')
    $button.append($('<b />', class: 'caret')).appendTo($buttonGroup)
    $dropdown = $('<ul />', class: 'dropdown-menu').appendTo($buttonGroup)
    @createDropdownListItem('richText', I18n.translate('javascript.editor.viewModes.richText'), 'font').appendTo($dropdown)
    @createDropdownListItem('html', I18n.translate('javascript.editor.viewModes.html'), 'code').appendTo($dropdown)
    @createDropdownListItem('preview', I18n.translate('javascript.editor.viewModes.preview'), 'file-o').appendTo($dropdown)
    $buttonGroup

  getEditor: ->
    # @toolbar.activeEditor does not work here, because it may not be set yet
    _(@toolbar.editors).first()

  onCreateControl: ->
    @refreshControlState()

  execCommand: ->
    # do nothing when caret button is clicked

  refreshControlState: ->
    super
    @queryDropdownItemStates()
    true

  queryDropdownItemStates: ->
    viewMode = @getEditor().options.viewMode
    $dropdown = @$control.find('.dropdown-menu')
    $buttons = $dropdown.find('li').removeClass('active')
    $buttons.filter(-> $(@).data('viewMode') == viewMode).addClass('active')

  createDropdownListItem: (viewMode, caption, icon) ->
    $item = $('<li />').attr('data-view-mode', viewMode)
    $link = $('<a />', href: '#').appendTo($item)
    $link.html("<span class='prepend-icon'><i class='fa fa-fw fa-#{icon}'></i><span class='caption'>#{caption}</span></span>")
    $link.click (event) =>
      event.preventDefault()
      @getEditor().changeViewMode(viewMode, true)
    $item

@Editor.Control.register('viewMode', @Editor.Control.ViewMode)