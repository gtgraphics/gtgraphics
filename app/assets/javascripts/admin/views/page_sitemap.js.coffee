$(document).ready ->
  $pageSitemap = $('#page_sitemap')
  $pageEditor = $('#page_content')

  $pageSitemap.affix
    offset:
      top: ->
        $('.navbar').outerHeight(true)
      bottom: ->
        $('footer').outerHeight(true)


  $('li.page', $pageSitemap)
    .draggable(
      revert: 'invalid'
      appendTo: '#page_sitemap'
      helper: ->
        $('<ul />', class: 'drag-helper').append($(this).clone())
    )
    .droppable(
      activeClass: 'dragging'
      hoverClass: 'dragover'
      accept: 'li.page'
      drop: (event, ui) ->
        
    )


  $pageSitemap.on 'click', 'a', (event) ->
    event.preventDefault()

    $link = $(@)
    $listItem = $link.closest('li')

    # Load Page Editor
    url = $link.attr('href')
    if url != $pageSitemap.data('currentUrl')
      $pageSitemap.data('currentUrl', url)
      $pageEditor.load url, ->
        $pageEditor.prepare()

    # Descendants
    if $listItem.hasClass('with-descendants')
      if $listItem.hasClass('active')
        $listItem.toggleClass('open')
      else
        $listItem.addClass('open')
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

    $('li', $pageSitemap).removeClass('active')
    $listItem.addClass('active')