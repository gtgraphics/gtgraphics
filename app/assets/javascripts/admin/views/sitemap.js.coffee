$(document).ready ->

  $('.tree').nestable(maxDepth: 20)

  $('.tree').on 'change', (event) ->
    console.log event