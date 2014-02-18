$(document).ready ->
  $.timeago.settings.allowFuture = true  
  $.timeago.settings.strings =
    prefixAgo: I18n.translate('timeago.prefixAgo')
    prefixFromNow: I18n.translate('timeago.prefixFromNow')
    suffixAgo: I18n.translate('timeago.suffixAgo')
    suffixFromNow: I18n.translate('timeago.suffixFromNow')
    seconds: (seconds) -> I18n.translate('timeago.seconds', seconds: seconds)
    minute: (minutes) -> I18n.translate('timeago.minute', minutes: minutes)
    minutes: (minutes) -> I18n.translate('timeago.minutes', minutes: minutes)
    hour: (hours) -> I18n.translate('timeago.hour', hours: hours)
    hours: (hours) -> I18n.translate('timeago.hours', hours: hours)
    day: (days) -> I18n.translate('timeago.day', days: days)
    days: (days) -> I18n.translate('timeago.days', days: days)
    month: (months) -> I18n.translate('timeago.month', months: months)
    months: (months) -> I18n.translate('timeago.months', months: months)
    year: (years) -> I18n.translate('timeago.year', years: years)
    years: (years) -> I18n.translate('timeago.years', years: years)

jQuery.prepare ->
  $('time.timeago', @).timeago()