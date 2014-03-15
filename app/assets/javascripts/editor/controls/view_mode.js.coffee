class @Editor.Controls.ViewMode extends @Editor.Controls.ButtonControl
  createControl: ->
    $buttonGroup = $('<div />', class: 'btn-group pull-right')
    $button = $('<button />', class: 'btn btn-default btn-sm dropdown-toggle', type: 'button', tabindex: '-1', 'data-toggle': 'dropdown')
    $button.append($('<b />', class: 'caret')).appendTo($buttonGroup)
    $dropdown = $('<ul />', class: 'dropdown-menu').appendTo($buttonGroup)
    @createDropdownListItem('richText', I18n.translate('editor.viewModes.richText'), 'font').appendTo($dropdown)
    @createDropdownListItem('html', I18n.translate('editor.viewModes.html'), 'code').appendTo($dropdown)
    @createDropdownListItem('preview', I18n.translate('editor.viewModes.preview'), 'file-o').appendTo($dropdown)
    $buttonGroup

  onCreateControl: ->
    @refreshControlState()

  execCommand: ->
    # do nothing when caret button is clicked

  refreshControlState: ->
    super
    @queryDropdownItemStates()
    true

  getViewMode: ->
    @toolbar.editor.viewMode

  queryDropdownItemStates: ->
    $dropdown = @renderedControl.find('.dropdown-menu')
    $buttons = $dropdown.find('li').removeClass('active')
    $buttons.filter(-> $(@).data('viewMode') == @toolbar.editor.viewMode).addClass('active') if @toolbar.editor

  createDropdownListItem: (viewMode, caption, icon) ->
    $item = $('<li />').attr('data-view-mode', viewMode)
    $link = $('<a />', href: '#').appendTo($item)
    $link.html("<span class='prepend-icon'><i class='fa fa-fw fa-#{icon}'></i><span class='caption'>#{caption}</span></span>")
    $link.click (event) =>
      event.preventDefault()
      @toolbar.editor.changeViewMode(viewMode, true)
    $item

@Editor.Controls.register('viewMode', @Editor.Controls.ViewMode)