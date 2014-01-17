Array::remove = (element) ->
  index = 0
  while index < @length
    if @[index] is element
      @splice(index, 1)
      index--
    index++
  @