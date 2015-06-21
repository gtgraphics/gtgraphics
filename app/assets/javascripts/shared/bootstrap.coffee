jQuery.prepare ->
  # Popover
  $('[data-toggle=popover]', @).popover()
  $('a[rel=popover]', @).popover()

  # Tooltip
  $('[data-toggle=tooltip]', @).tooltip()
  $('a[rel=tooltip]', @).tooltip()