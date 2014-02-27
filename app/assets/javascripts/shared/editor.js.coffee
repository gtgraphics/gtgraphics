jQuery.prepare ->
  $('.editor', @).editor()

  $('.simple-editor', @).editor
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['orderedList', 'unorderedList']
    ]

  #$('.region', @).editor
  #  controls: [
  #    ['save'],
  #    ['bold', 'italic', 'underline', 'strikethrough'],
  #    ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
  #    ['orderedList', 'unorderedList', 'indent', 'outdent'],
  #    #['link', 'unlink'],
  #    #'image',
  #    'view_mode'
  #  ]

$(document).on 'click', 'body.editing .region', ->
  $region = $(@)

  if $region.hasClass('editing')
    $region.removeClass('editing')
    $region.html($region.data('originalHtml'))
    $region.removeData('originalHtml')
  else
    $region.addClass('editing')
    $region.data('originalHtml', $region.html())

    label = $region.data('region')
    url = $region.data('url')

    console.log "Loading #{label}..."

    jQuery.get url, (html) ->
      console.log html
      $region.html(html)