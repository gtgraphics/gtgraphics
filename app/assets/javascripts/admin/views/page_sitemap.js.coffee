$(document).ready ->
  $pageSitemap = $('#page_sitemap')

  $pageSitemap.on 'click', '.toggle-descendants', (event) ->
    event.preventDefault()

    $link = $(@)
    $listItem = $link.closest('li')
    $listItem.toggleClass('open')

    if $('ul', $listItem).none()
      $listItem.addClass('loading')
      jQuery.ajax
        url: $pageSitemap.data('url')
        data: { parent_id: $listItem.data('pageId') }
        dataType: 'html'
        success: (html) ->
          $listItem.append(html)
        complete: ->
          $listItem.removeClass('loading')
