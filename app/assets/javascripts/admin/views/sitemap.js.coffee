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
        $checkbox = $('<input />', type: 'checkbox', name: 'page_ids[]', value: node.id).prependTo($title)
        $checkbox.click (event) ->
          event.stopPropagation()
        
        $listItem.on 'ifChecked', ':checkbox', (event) ->
          event.stopPropagation()

          # Handle Child Checkboxes Behavior
          $childCheckboxes = $checkbox.closest('li').children('ul').children('li').find(':checkbox')
          $childCheckboxes.prop('checked', true)
          $childCheckboxes.iCheck('update')

          # Handle Parent Checkboxes Behavior
          $parentCheckboxes = $checkbox.parents().find(':checkbox')

          $parentCheckboxes.attr('indeterminate', true)
          $parentCheckboxes.iCheck('update')

        $listItem.on 'ifUnchecked', ':checkbox', (event) ->
          event.stopPropagation()

          # Handle Child Checkboxes Behavior
          $childCheckboxes = $checkbox.closest('li').children('ul').children('li').find(':checkbox')
          if $childCheckboxes.all(':checked')
            $childCheckboxes.prop('checked', false)
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