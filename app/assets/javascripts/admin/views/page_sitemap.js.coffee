setEvents = ($scope) ->
  $('li.page', $scope)
    .draggable
      distance: 5
      revert: 'invalid'
      appendTo: '#page_sitemap'
      containment: '#page_sitemap'
      helper: ->
        $('<ul />', class: 'drag-helper').append($(@).clone())
    .droppable
      greedy: true
      activeClass: 'dragging'
      hoverClass: 'dragover'
      accept: 'li.page'
      drop: (event, ui) ->

jQuery.prepare ->
  setEvents(@)

$(document).ready ->
  $pageSitemap = $('#page_sitemap')
  $pageContent = $('#page_content')

  setEvents($pageSitemap)

  $pageSitemap.on 'click', '.toggle-children', (event) ->
    event.preventDefault()
    $button = $(@)
    $listItem = $button.closest('li')

    if $listItem.hasClass('with-descendants')
      if $('ul', $listItem).none()
        $listItem.addClass('opening')
        $button.prop('disabled', true)
        jQuery.ajax
          url: $pageSitemap.data('url')
          data: { id: $listItem.data('pageId') }
          dataType: 'html'
          success: (html) ->
            $(html).appendTo($listItem).prepare()
            $listItem.addClass('open')
          complete: ->
            $listItem.removeClass('opening')
            $button.prop('disabled', false)
      else
        $listItem.toggleClass('open')

  $pageSitemap.on 'click', '.open-page', (event) ->
    event.preventDefault()
    
    $link = $(@)
    $listItem = $link.closest('li')
    
    url = $link.attr('href')
    if url != $pageSitemap.data('currentUrl')
      $pageSitemap.data('currentUrl', url)
      $pageContent.load url, ->
        $pageContent.prepare()

    $('li', $pageSitemap).removeClass('active')
    $listItem.addClass('active')