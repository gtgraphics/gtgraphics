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
    onCreateLi: (node, $listItem) ->
      if node.destroyable
        $title = $listItem.find('.jqtree-title')
        $checkbox = $('<input />', type: 'checkbox', value: node.id).prependTo($title)
        $checkbox.click (event) ->
          event.stopPropagation()
        $checkbox.on 'ifChanged', (event) ->
          $childCheckboxes = $checkbox.closest('li').children('ul').children('li').find(':check')
          if $checkbox.prop('indeterminate')
            $checkbox.prop('indeterminate', false).prop('checked', true)
            $childCheckboxes.prop('checked', true)
          else


          $checkbox.iCheck('update')
          $childCheckboxes.iCheck('update')

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