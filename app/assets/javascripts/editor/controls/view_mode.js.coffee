class @Editor.Controls.ViewMode extends @Editor.Controls.Base
  constructor: (@editor, $controls) ->
    super
    @isRichTextControl = false

  createControl: ->
    $group = $('<div />', class: 'btn-group pull-right')

    $editor = super.appendTo($group)
    $editor.text(I18n.translate('editor.view_modes.editor'))
    $editor.attr('data-view-mode', 'editor')
    @applyControlEvents($editor)

    $preview = super.appendTo($group)
    $preview.text(I18n.translate('editor.view_modes.preview'))
    $preview.attr('data-view-mode', 'preview')
    @applyControlEvents($preview)

    $html = super.appendTo($group)
    $html.text(I18n.translate('editor.view_modes.html'))
    $html.attr('data-view-mode', 'html')
    @applyControlEvents($html)

    $group

  execCommand: ->
    @editor.changeViewMode()

  queryActive: ->
    #@editor.viewMode == ''
    false

  activate: ->
    false

  deactivate: ->
    false

  applyEvents: ->
    false

  refreshState: ->
    $buttons = @control.find('button').removeClass('active')
    $buttons.filter("[data-view-mode='#{@editor.viewMode}']").addClass('active')

  applyControlEvents: ($button) ->
    $button.click =>
      @editor.changeViewMode($button.data('viewMode'), true)

@Editor.Controls.register('view_mode', @Editor.Controls.ViewMode)