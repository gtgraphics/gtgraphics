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
      return false
      if node.destroyable

        $element = $listItem.children('.jqtree-element')
        $checkbox = $('<input />', type: 'checkbox', name: 'page_ids[]', value: node.id).prependTo($element)
        
        $checkbox.on 'ifChanged', (event) ->
          #event.stopPropagation()

          #$checkbox.prop('indeterminate', false).iCheck('update')

          $parentCheckboxes = $checkbox.parents('.jqtree-folder').children('.jqtree-element').find(':checkbox')
          $siblingCheckboxes = $checkbox.closest('li').siblings().find(':checkbox')
          $childCheckboxes = $checkbox.closest('li').children('ul').children('li').find(':checkbox')

          console.log $parentCheckboxes

          if $checkbox.prop('checked')
            $parentCheckboxes.each ->
              $parentCheckbox = $(@)
              unless $parentCheckbox.prop('checked')
                $parentCheckbox.attr('indeterminate', true).iCheck('update')
          else
            $parentCheckboxes.each ->
              $parentCheckbox = $(@)
              unless $parentCheckbox.prop('checked')
                $parentCheckbox.attr('indeterminate', false).iCheck('update')




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