class @Editor.Controls.Save extends @Editor.Controls.ButtonControl
  executeCommandSync: ->
    confirm 'Do you really want to save?'

  getCaption: ->
    I18n.translate('editor.save')

  getIcon: ->
    'save'

@Editor.Controls.register('save', @Editor.Controls.Save)