class @Editor.Controls.ViewMode extends @Editor.Controls.ControlGroup
  constructor: (@editor, $controls) ->
    super
    @isRichTextControl = false
    @editor.input.on 'viewModeChanged.editor', =>
      @refreshState()

  createControl: ->
    $group = super

    $editor = @createButton().appendTo($group)
    $editor.text(I18n.translate('editor.view_modes.editor'))
    $editor.attr('data-view-mode', 'editor')
    @applyControlEvents($editor)

    $html = @createButton().appendTo($group)
    $html.text(I18n.translate('editor.view_modes.html'))
    $html.attr('data-view-mode', 'html')
    @applyControlEvents($html)

    $preview = @createButton().appendTo($group)
    $preview.text(I18n.translate('editor.view_modes.preview'))
    $preview.attr('data-view-mode', 'preview')
    @applyControlEvents($preview)

    $group

  execCommand: ->
    @editor.changeViewMode()

  refreshState: ->
    $buttons = @control.find('button').removeClass('active')
    $buttons.filter("[data-view-mode='#{@editor.viewMode}']").addClass('active')

  applyControlEvents: ($button) ->
    $button.click =>
      @editor.changeViewMode($button.data('viewMode'), true)

@Editor.Controls.register('view_mode', @Editor.Controls.ViewMode)