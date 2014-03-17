class @Editor.Control.Save extends @Editor.Control.ButtonControl
  executeCommandSync: ->
    if confirm 'Do you really want to save?'
      alert "Saved to #{Editor.Control.Save.url}"

  getCaption: ->
    I18n.translate('editor.save')

  getIcon: ->
    'save'

@Editor.Control.register('save', @Editor.Control.Save)