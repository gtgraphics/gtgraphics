class @Editor.Controls.ControlGroup extends @Editor.Controls.Base
  createControl: ->
    $('<div />', class: 'btn-group pull-right')

  queryActive: ->
    #@editor.viewMode == ''
    false

  activate: ->
    false

  deactivate: ->
    false

  applyEvents: ->
    false
