$(document).ready ->
  $('.gtg-admin-toolbar').affix
    offset:
      top: ->
        $('.gtg-admin-toolbar').offset().top - $('.navbar').height()
