( ($) ->

  $.fn.prepare = ->
    @trigger('prepare')

  $.prepare = (callback) ->
    $(document).on 'prepare', (event) ->
      $scope = $(event.target)
      callback.apply($scope)

  $(document).ready ->
    $(document).prepare()

) jQuery