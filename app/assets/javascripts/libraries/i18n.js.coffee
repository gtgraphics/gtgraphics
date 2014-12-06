window.I18n ||= {}
 
VALID_OPTIONS = ['scope', 'locale', 'default', 'fallbacks']
 
 
humanizeKeypath = (keypath) ->
  console.warn "I18n: no translation found for #{keypath}"
  _(keypath.split('.')).chain().last().humanize().value()
 
sanitizeKeypath = (keypath) ->
  if _(keypath).isArray()
    console.log keypath
    keypath = _(keypath).chain().flatten().compact().collect((subpath) -> a).value()
  else
    keypath = keypath.split('.')
  _(keypath).collect((subpath) -> "['#{subpath}']").join('')
 
tryToInterpolate = (str, interpolations)  ->
  if _(str).isObject()
    str
  else
    str.interpolate(interpolations)


_(I18n).extend
 
  t: (keypath, options = {}) ->
    @translate(keypath, options)
 
  translate: (keypath, options = {}) ->
    throw "I18n: no keypath defined" unless keypath
    throw "I18n: no translations found" unless @translations
    
    interpolations = _(options).omit(VALID_OPTIONS)
    options = _(options).chain().pick(VALID_OPTIONS).defaults(locale: I18n.locale, fallbacks: true).value()
 
    fallbacks = {}
    fallbacks = I18n.fallbacks[options.locale] if options.fallbacks and _(I18n.fallbacks).has(options.locale)
    fallbacks[options.locale] = [options.locale] if _(fallbacks).isEmpty()
 
    translations = _(fallbacks).collect (locale) =>
      if _(@translations).has(locale)
        try
          eval("I18n.translations.#{locale}#{sanitizeKeypath(keypath)}")
        catch
          null
 
    translation = _(translations).chain().select((translation) -> translation?).first().value()
    if translation?
      tryToInterpolate(translation, interpolations)
    else
      if options.default
        tryToInterpolate(options.default, interpolations)
      else
        humanizeKeypath(keypath)