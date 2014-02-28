class @Editor.Controls.ControlGroup extends @Editor.Controls.Control
  createControl: ->
    $('<div />', class: 'btn-group pull-right')

  queryActive: ->
    #@editor.viewMode == ''
    false

  activate: ->
    false

  deactivate: ->
    false

  enable: ->
    false

  disable: ->
    false

  applyEvents: ->
    false
