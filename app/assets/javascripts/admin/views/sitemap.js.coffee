$(document).ready ->

  $sitemap = $('#sitemap')
  $pageContent = $('#page_content')

  $sitemap.tree
    selectable: false
    useContextMenu: false
    dragAndDrop: true
    autoOpen: true
    openFolderDelay: 2000
    keyboardSupport: false
    closedIcon: '<b class="caret-right"></b>'
    openedIcon: '<b class="caret"></b>'
    onCreateLi: (node, $listItem) ->
      #$title = $listItem.children('.jqtree-element').find('.jqtree-title')
      #$link = $('<a />', href: node.url).text(node.name)
      #$title.html($link)
      
      $listItem
    onIsMoveHandle: ($element) ->
      $element.is('.jqtree-title')

  $sitemap.on 'tree.refresh', ->
    $sitemap.prepare()

  $sitemap.on 'tree.select', (event) ->
    node = event.node
    if node
      $pageContent.load node.url, ->
        $pageContent.prepare()
    else
      # unselect
      $pageContent.empty()

  $sitemap.on 'tree.move', (event) ->
    event.preventDefault()

    moveInfo = event.move_info
    movedNode = moveInfo.moved_node
    moveUrl = movedNode.move_url
    targetNodeId = moveInfo.target_node.id

    jQuery.ajax
      url: moveUrl
      type: 'post'
      data: { _method: 'patch', to: targetNodeId, position: moveInfo.position }
      success: ->
        selectedNodeId = $sitemap.tree('getState').selected_node
        moveInfo.do_move()
        if movedNode.id == selectedNodeId
          $pageContent.load movedNode.url, ->
            $pageContent.prepare()