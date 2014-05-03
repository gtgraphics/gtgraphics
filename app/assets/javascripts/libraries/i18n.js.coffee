window.I18n ||= {}

VALID_OPTIONS = ['scope', 'locale', 'default', 'fallbacks']

humanizeKeypath = (keypath) ->
  console.warn "I18n: no translation found for #{keypath}"
  _(keypath.split('.')).chain().last().humanize().value()

sanitizeKeypath = (keypath) ->
  str = ""
  if keypath
    if _(keypath).isArray()
      str += _(keypath).chain().flatten().compact().value().join('.')
    else
      str += keypath
  str

buildEvalString = (keypath, locale) ->
  ['I18n.translations', locale, sanitizeKeypath(keypath)].join('.')

_(I18n).extend

  t: (keypath, options = {}) ->
    @translate(keypath, options)

  translate: (keypath, options = {}) ->
    interpolations = _(options).omit(VALID_OPTIONS)
    options = _(options).chain().pick(VALID_OPTIONS).defaults(locale: I18n.locale, fallbacks: true).value()

    fallbacks = {}
    fallbacks = I18n.fallbacks[options.locale] if options.fallbacks and _(I18n.fallbacks).has(options.locale)
    fallbacks[options.locale] = [options.locale] if _(fallbacks).isEmpty()

    translations = _(fallbacks).collect (locale) =>
      if _(@translations).has(locale)
        try
          eval(buildEvalString([options.scope, keypath], locale))
        catch
          null

    translation = _(translations).chain().select((translation) -> translation?).first().value()
    if translation?
      if _(translation).isObject()
        translation
      else
        translation.interpolate(interpolations)
    else
      options.default || humanizeKeypath(keypath)
