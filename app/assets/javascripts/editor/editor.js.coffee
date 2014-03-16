# An Editor is for a single Region

availableControls = []

@Editor = {
  Controls:
    get: (key) ->
      control = availableControls[key]
      jQuery.error "Control not found: #{key}" unless control
      control
    init: (key, toolbar) ->
      klass = @get(key)
      new klass(toolbar)
    register: (key, controlClass) ->
      availableControls[key] = controlClass
    unregister: (key) ->
      delete availableControls[key]
}