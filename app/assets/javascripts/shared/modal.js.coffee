$(document).on 'hidden.bs.modal', ->
  $('#modal').remove()

$(document).on 'shown.bs.modal', ->
  $('#modal').prepare()