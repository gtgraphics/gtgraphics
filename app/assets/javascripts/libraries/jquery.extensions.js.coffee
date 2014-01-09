(($) ->
 
  $.fn.any = (filter) ->
    if filter
      $scope = @filter(filter)
    else
      $scope = @
    $scope.length > 0
    
  $.fn.none = (filter) ->
    if filter
      $scope = @filter(filter)
    else
      $scope = @
    $scope.length == 0
 
) jQuery