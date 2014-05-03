class @Editor.Control.PageSettings extends @Editor.Control.ButtonControl
  executeCommandSync: ->
    Turbolinks.visit(Editor.Control.PageSettings.url)

  getCaption: ->
    I18n.translate('javascript.editor.pageSettings')

  getIcon: ->
    'cogs'

@Editor.Control.register('pageSettings', @Editor.Control.PageSettings)