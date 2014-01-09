Array::first = ->
  @[0]

Array::include = (element, fromIndex = 0) ->
  @index(element, fromIndex) >= 0

Array::index = (element, fromIndex = 0) ->
  jQuery.inArray(element, @, fromIndex)

Array::last = ->
  @[@length-1]

Array::remove = (element) ->
  index = 0
  while index < @length
    if @[index] is element
      @splice(index, 1)
      index--
    index++
  @

Array::sortBy = (property) ->
  @sort (a, b) ->
    aValue = eval("a.#{property}")
    bValue = eval("b.#{property}")
    if aValue and bValue
      parseInt(aValue) - parseInt(bValue)
    else
      throw "at least one element does not contain property: #{property}"

Array::uniq = ->
  inputArray = @
  outputArray = []
  index = 0
  while index < inputArray.length
    element = inputArray[index]
    outputArray.push(element) unless outputArray.include(element)
    index++
  outputArray