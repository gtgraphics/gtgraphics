$(document).ready ->

  $sitemap = $('#sitemap')
  $pageContent = $('#page_content')

  $sitemap.tree
    useContextMenu: false
    dragAndDrop: true
    autoOpen: true
    openFolderDelay: 2000
    closedIcon: '<i class="caret-right"></i>'
    openedIcon: '<i class="caret"></i>'

  $sitemap.on 'tree.select', (event) ->
    node = event.node
    if node
      $pageContent.load(node.url)
    else
      # unselect
      $pageContent.empty()

  $sitemap.on 'tree.move', (event) ->
    event.preventDefault()
    moveInfo = event.move_info
    movedNodeId = moveInfo.moved_node.id
    moveUrl = moveInfo.moved_node.move_url
    targetNodeId = moveInfo.target_node.id

    jQuery.ajax
      url: moveUrl
      type: 'post'
      data: { _method: 'patch', to: targetNodeId, position: moveInfo.position }
      success: ->
        console.log moveInfo
        moveInfo.do_move