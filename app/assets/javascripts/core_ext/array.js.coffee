Array::first = ->
  @[0]

Array::last = ->
  @[@length-1]

Array::sortBy = (property) ->
  @sort (a, b) ->
    aValue = eval("a.#{property}")
    bValue = eval("b.#{property}")
    if aValue and bValue
      parseInt(aValue) - parseInt(bValue)
    else
      throw "at least one element does not contain property: #{property}"

Array::uniq = ->
  o = {}
  i = undefined
  l = @length
  r = []
  i = 0
  while i < l
    o[this[i]] = this[i]
    i += 1
  for i of o
    r.push o[i]
  r