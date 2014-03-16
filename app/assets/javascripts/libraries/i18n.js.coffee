window.I18n ||= {}

humanizeKeypath = (keypath) ->
  keypathArray = keypath.split('.')
  keypathStr = keypathArray[keypathArray.length - 1]
  keypathStr = keypathStr.charAt(0).toUpperCase() + keypathStr.slice(1);
  keypathStr.replace('_', ' ')

jQuery.extend I18n,

  t: (keypath, options = {}) ->
    @translate(keypath, options)

  translate: (keypath, options = {}) ->
    options = $.extend({}, { locale: I18n.locale }, options)
    unless options.locale
      console.error "I18n: no locale defined"
      return
    if !@translations[options.locale] or @translations[options.locale].length == 0
      console.warn "I18n: no translations found (#{keypath})"
      humanizeKeypath(keypath)
    else
      scope = options.scope
      delete options.scope
      evalStr = "this.translations.#{options.locale}"
      if keypath
        keypathArray = keypath.split('.')
        if scope
          if jQuery.isArray(scope)
            jQuery.each scope, ->
              evalStr += ".#{@}"
          else
            evalStr += ".#{scope}"
        jQuery.each keypathArray, ->
          evalStr += ".#{@}"
      
      try
        translations = eval(evalStr)
      catch
        translations = null

      if jQuery.isPlainObject(translations)
        translations
      else
        if translations? and translations != undefined
          translations.interpolate(options)
        else
          if options.default? and options.default != undefined
            options.default
          else
            console.warn "I18n: no translation found for #{keypath}"
            humanizeKeypath(keypath)