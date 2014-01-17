(($) ->

  $.fn.all = (filter) ->
    jQuery.error 'filter argument is required' unless filter
    @length == @filter(filter).length
 
  $.fn.any = (filter) ->
    if filter
      $scope = @filter(filter)
    else
      $scope = @
    $scope.length > 0
    
  $.fn.many = (filter) ->
    if filter
      $scope = @filter(filter)
    else
      $scope = @
    $scope.length > 1

  $.fn.none = (filter) ->
    if filter
      $scope = @filter(filter)
    else
      $scope = @
    $scope.length == 0


  # Select

  $.fn.options = ->
    @filter('select').find('option').map(-> $(@).val()).toArray()

 
) jQuery