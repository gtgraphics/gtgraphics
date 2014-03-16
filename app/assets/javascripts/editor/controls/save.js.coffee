class @Editor.Controls.Save extends @Editor.Controls.ButtonControl
  executeCommandSync: ->
    if confirm 'Do you really want to save?'
      alert "Saved to #{Editor.Controls.Save.url}"

  getCaption: ->
    I18n.translate('editor.save')

  getIcon: ->
    'save'

@Editor.Controls.register('save', @Editor.Controls.Save)