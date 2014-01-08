(($) ->
 
  $.fn.any ->
    @length > 0
    
  $.fn.none ->
    @length == 0
 
) jQuery