$(document).on 'hidden.bs.modal', ->
  $('#modal').remove()

$(document).on 'show.bs.modal', ->
  $('#modal').prepare()