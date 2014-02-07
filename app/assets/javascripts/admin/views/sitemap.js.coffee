selectedNode = null

$(document).ready ->

  $sitemap = $('#sitemap')
  $pageContent = $('#page_content')

  $sitemap.tree
    selectable: true
    useContextMenu: false
    dragAndDrop: true
    autoOpen: true
    openFolderDelay: 2000
    keyboardSupport: true
    closedIcon: '<b class="caret-right"></b>'
    openedIcon: '<b class="caret"></b>'
    onCreateLi: (node, $listItem) ->
      unless node.root
        $dragHandle = $('<div />', class: 'jqtree-handle')
        $dragHandle.html('<i class="fa fa-bars"></i>')
        $listItem.find('.jqtree-title').after($dragHandle)
      $element = $listItem.attr('data-url', node.url).find('.jqtree-element')

    onIsMoveHandle: ($element) ->
      $element.is('.jqtree-handle')

    #onCanSelectNode: (node) ->
    #  console.log node

    onCanMove: (node) ->
      !node.root

    onCanMoveTo: (movedNode, targetNode, position) ->
      !(targetNode.root and position != 'inside')

  $sitemap.on 'tree.refresh', ->
    $sitemap.prepare()

  $sitemap.on 'tree.select', (event) ->
    selectedNode = event.node
    if selectedNode
      $pageContent.load selectedNode.url, ->
        $pageContent.prepare()
    else
      # unselect
      $pageContent.empty()

  $sitemap.on 'tree.open tree.opening', (event) ->
    $sitemap.tree('addToSelection', selectedNode) if selectedNode

  $sitemap.on 'tree.move', (event) ->
    event.preventDefault()

    moveInfo = event.move_info
    movedNode = moveInfo.moved_node
    moveUrl = movedNode.move_url
    targetNode = moveInfo.target_node

    if !targetNode.root or (targetNode.root and moveInfo.position == 'inside')
      moveInfo.do_move()
      jQuery.ajax
        url: moveUrl
        type: 'post'
        data: { _method: 'patch', to: targetNode.id, position: moveInfo.position }
        success: ->
          selectedNodeId = $sitemap.tree('getState').selected_node
          #moveInfo.do_move()
          if movedNode.id == selectedNodeId
            $pageContent.load movedNode.url, ->
              $pageContent.prepare()

  $sitemap