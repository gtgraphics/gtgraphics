setEvents = ($scope) ->
  $('.node', $scope)
    .draggable
      distance: 5
      revert: 'invalid'
      appendTo: '#page_sitemap'
      containment: '#page_sitemap'
      helper: ->
        $list = $('<ul />', class: 'tree drag-helper')
        $listItem = $('<li />', class: 'with-descendants').appendTo($list)
        $(@).clone().appendTo($listItem)
        $list
    .droppable
      greedy: true
      activeClass: 'dragging'
      hoverClass: 'dragover'
      accept: ($source) ->
        $target = $(@)
        # prevent that parents can be moved to one of their children
        if $source.closest('li').children('ul').find('li > .node').is($target)
          false
        else
          '.node'
      drop: (event, ui) ->
        console.log "dropped it like it's hot"

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