( ($) ->

  window.I18n ||= {}

  humanizeKeypath = (keypath) ->
    keypathArray = keypath.split('.')
    keypathStr = keypathArray[keypathArray.length - 1]
    keypathStr = keypathStr.charAt(0).toUpperCase() + keypathStr.slice(1);
    keypathStr.replace('_', ' ')

  $.extend I18n,

    translate: (keypath, options = {}) ->
      if !@translations or @translations.length == 0
        console.warn "I18n: no translations found (#{keypath})"
        humanizeKeypath(keypath)
      else
        options = $.extend({}, options)
        scope = options.scope
        delete options.scope
        evalStr = "this.translations"
        if keypath
          keypathArray = keypath.split('.')
          if scope
            if $.isArray(scope)
              $.each scope, ->
                evalStr += ".#{@}"
            else
              evalStr += ".#{scope}"
          $.each keypathArray, ->
            evalStr += ".#{@}"
        
        try
          translations = eval(evalStr)
        catch
          translations = null

        if $.isPlainObject(translations)
          translations
        else
          if translations != undefined && translations != null
            translations.interpolate(options)
          else
            if options.default != undefined && options.default != null
              options.default
            else
              console.warn "I18n: no translation found for #{keypath}"
              humanizeKeypath(keypath)

) jQuery