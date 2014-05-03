jQuery.timeago.settings.allowFuture = true  
jQuery.timeago.settings.strings =
  prefixAgo: -> I18n.translate('javascript.timeago.prefixAgo')
  prefixFromNow: -> I18n.translate('javascript.timeago.prefixFromNow')
  suffixAgo: -> I18n.translate('javascript.timeago.suffixAgo')
  suffixFromNow: -> I18n.translate('javascript.timeago.suffixFromNow')
  seconds: (seconds) -> I18n.translate('javascript.timeago.seconds', seconds: seconds)
  minute: (minutes) -> I18n.translate('javascript.timeago.minute', minutes: minutes)
  minutes: (minutes) -> I18n.translate('javascript.timeago.minutes', minutes: minutes)
  hour: (hours) -> I18n.translate('javascript.timeago.hour', hours: hours)
  hours: (hours) -> I18n.translate('javascript.timeago.hours', hours: hours)
  day: (days) -> I18n.translate('javascript.timeago.day', days: days)
  days: (days) -> I18n.translate('javascript.timeago.days', days: days)
  month: (months) -> I18n.translate('javascript.timeago.month', months: months)
  months: (months) -> I18n.translate('javascript.timeago.months', months: months)
  year: (years) -> I18n.translate('javascript.timeago.year', years: years)
  years: (years) -> I18n.translate('javascript.timeago.years', years: years)

jQuery.prepare ->
  $('time.timeago', @).timeago()