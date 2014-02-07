selectedNode = null

$(document).ready ->

  # FIXME Events become re-applied to #sitemap on each request!!!

  $sitemap = $('#sitemap')
  $pageContent = $('#page_content')

  return if $sitemap.hasClass('loaded')
  $sitemap.addClass('loaded')

  console.log 'init sitemap'

  $sitemap.tree
    data: []
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
      $listItem.attr('data-id', node.id)
      $listItem.attr('data-url', node.url)
      selectedNode = node if node.active
      #$sitemap.tree('selectNode', selectedNode)
      #$element = $listItem.find('.jqtree-element')
      #$title = $element.find('.jqtree-title').wrap($('<a />', href: node.url))

    onIsMoveHandle: ($element) ->
      $element.is('.jqtree-handle')

    onCanMove: (node) ->
      !node.root

    onCanMoveTo: (movedNode, targetNode, position) ->
      !(targetNode.root and position != 'inside')

  $sitemap.on 'tree.init', ->
    $sitemap.tree('addToSelection', selectedNode)

  $sitemap.on 'tree.refresh', ->
    $sitemap.tree('addToSelection', selectedNode)
    $sitemap.prepare()

  $sitemap.on 'tree.click', (event) ->
    event.preventDefault() if $sitemap.tree('isNodeSelected', event.node)

  $sitemap.on 'tree.select', (event) ->
    if selectedNode != event.node
      selectedNode = event.node
      console.log selectedNode
      Turbolinks.visit(selectedNode.url)

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