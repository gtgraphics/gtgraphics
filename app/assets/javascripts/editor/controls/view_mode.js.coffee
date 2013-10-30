class @Editor.Controls.ViewMode extends @Editor.Controls.ControlGroup
  VIEW_MODE_TRANSITIONS = {
    'editor': 'html'
    'html': 'preview'
    'preview': 'editor'
  }

  constructor: (@editor, $controls) ->
    super
    @isRichTextControl = false
    @editor.input.on 'viewModeChanged.editor', =>
      @refreshState()

  createControl: ->
    $group = super

    #$selected = @createButton().appendTo($group)
    #$selected.addClass('selected')
    #$selected.click (event) =>
    #  event.preventDefault()
    #  nextViewMode = VIEW_MODE_TRANSITIONS[@editor.viewMode]
    #  @editor.changeViewMode(nextViewMode, true)

    $caret = $('<button />', class: 'btn btn-default btn-mini dropdown-toggle', type: 'button', 'data-toggle': 'dropdown')
    $caret.append($('<i />', class: 'fa fa-chevron-down')).appendTo($group)

    $dropdown = $('<ul />', class: 'dropdown-menu').appendTo($group)
    
    $editor = $('<li><a /></li>').appendTo($dropdown).find('a').attr('href', '#')
    $editor.html("<i class='fa fa-font'></i> " + I18n.translate('editor.view_modes.editor'))
    #$editor.text(I18n.translate('editor.view_modes.editor'))
    $editor.attr('data-view-mode', 'editor')
    @applyControlEvents($editor)

    $html = $('<li><a /></li>').appendTo($dropdown).find('a').attr('href', '#')
    $html.html("<i class='fa fa-code'></i> " + I18n.translate('editor.view_modes.html'))
    #$html.text(I18n.translate('editor.view_modes.html'))
    $html.attr('data-view-mode', 'html')
    @applyControlEvents($html)

    $preview = $('<li><a /></li>').appendTo($dropdown).find('a').attr('href', '#')
    $preview.html("<i class='fa fa-file-o'></i> " + I18n.translate('editor.view_modes.preview'))
    #$preview.text(I18n.translate('editor.view_modes.preview'))
    $preview.attr('data-view-mode', 'preview')
    @applyControlEvents($preview)

    #$editor = @createButton().appendTo($group)
    #$editor.text(I18n.translate('editor.view_modes.editor'))
    #$editor.attr('data-view-mode', 'editor')
    #@applyControlEvents($editor)

    #$html = @createButton().appendTo($group)
    #$html.text(I18n.translate('editor.view_modes.html'))
    #$html.attr('data-view-mode', 'html')
    #@applyControlEvents($html)

    #$preview = @createButton().appendTo($group)
    #$preview.text(I18n.translate('editor.view_modes.preview'))
    #$preview.attr('data-view-mode', 'preview')
    #@applyControlEvents($preview)

    $group

  execCommand: ->
    @editor.changeViewMode()

  refreshState: ->
    $dropdown = @control.find('.dropdown-menu')
    $buttons = $dropdown.find('li').removeClass('active')
    $selected = $buttons.find("a[data-view-mode='#{@editor.viewMode}']").closest('li').addClass('active')
    @control.find('.selected').html($selected.find('a').html())

  applyControlEvents: ($button) ->
    $button.click (event) =>
      event.preventDefault()
      viewMode = $button.data('viewMode')
      @editor.changeViewMode(viewMode, true)

@Editor.Controls.register('view_mode', @Editor.Controls.ViewMode)