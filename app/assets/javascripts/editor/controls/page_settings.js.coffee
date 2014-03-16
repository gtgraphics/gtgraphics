class @Editor.Controls.PageSettings extends @Editor.Controls.ButtonControl
  executeCommandSync: ->
    Turbolinks.visit(Editor.Controls.PageSettings.url)

  getCaption: ->
    I18n.translate('editor.pageSettings')

  getIcon: ->
    'cogs'

@Editor.Controls.register('pageSettings', @Editor.Controls.PageSettings)