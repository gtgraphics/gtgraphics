originalCursor = null
originalHtml = null

$(document).on 'page:fetch submit', ->
  $('body').addClass('loading')

  $container = $('.gtg-admin-breadcrumb-home')
  originalHtml = $container.html()
  $container.html('<i class="fa fa-spinner fa-fw fa-spin">')

$(document).on 'page:receive', ->
  $('body').removeClass('loading')

  if originalHtml
    $container = $('.gtg-admin-breadcrumb-home')
    $container.html(originalHtml)

# Tooltips Fix
$(document).on 'page:change', ->
  $('.tooltip').remove()