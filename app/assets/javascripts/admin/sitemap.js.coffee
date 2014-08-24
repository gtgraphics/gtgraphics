SITEMAP_SELECTOR = '#sitemap'

#$(document).ready ->
#  $('#sitemap_container').affix
#    offset:
#      top: ->
#        $('.gtg-admin-toolbar').offset().top - $('#navigation').outerHeight()

$(document).on 'page:change', ->
  $sitemap = $(SITEMAP_SELECTOR)
  $sitemap.tree
    data: $sitemap.data('pages')
    selectable: true
    useContextMenu: false
    dragAndDrop: true
    autoOpen: true
    openFolderDelay: 2000
    keyboardSupport: true
    saveState: true
    closedIcon: '<b class="caret-right"></b>'
    openedIcon: '<b class="caret"></b>'
    onCreateLi: (node, $listItem) ->
      $listItem.addClass(_(node.type).dasherize() + "-page")
      $listItem.addClass('movable') unless node.root
      $title = $listItem.find('.jqtree-title')

      switch node.type
        when 'redirection'
          $typeIndicator = $('<div />', class: 'page-type-indicator', title: node.human_type)
          $typeIndicator.tooltip(container: 'body')
          $typeIndicator.html('<i class="fa fa-share fa-fw"></i>')
          $title.after($typeIndicator)

      unless node.root
        $dragHandle = $('<div />', class: 'jqtree-handle')
        $dragHandle.html('<i class="fa fa-bars fa-fw"></i>')
        $title.after($dragHandle)
        $listItem.addClass('page-draft') unless node.published
    onIsMoveHandle: ($element) ->
      $element.is('.jqtree-handle')
    onCanMove: (node) ->
      !node.root
    onCanMoveTo: (movedNode, targetNode, position) ->
      !(targetNode.root and position != 'inside')
    onGetStateFromStorage: ->
      state = jQuery.cookie('sitemap_state')
      if state
        openNodes = _.map state.split(' '), (id) -> parseInt(id)
      else
        return false
      JSON.stringify({ open_nodes: openNodes, selected_node: null })
    onSetStateFromStorage: (state) ->
      state = jQuery.parseJSON(state)
      jQuery.cookie('sitemap_state', state.open_nodes.join(' '), path: '/')

  # Mark selected node as active and scroll to it if necessary
  selectedNode = $sitemap.tree('getNodeById', $sitemap.data('selectedPageId'))
  $sitemap.tree('addToSelection', selectedNode) if selectedNode

  # Check if a lazily loaded node is the selected one
  $sitemap.on 'tree.load_data', (event) ->
    _.each event.tree_data, (node) ->
      selectedNode = $sitemap.tree('getNodeById', $sitemap.data('selectedPageId'))
      $sitemap.tree('addToSelection', selectedNode) if selectedNode

  # Prevent nodes from being unselected
  $sitemap.on 'tree.click', (event) ->
    event.preventDefault() if $sitemap.tree('isNodeSelected', event.node)

  # Visit the particular page via Turbolinks when a node is selected
  $sitemap.on 'tree.select', (event) ->
    selectedNode = event.node
    Turbolinks.visit(selectedNode.url) if selectedNode

  # Fix for jqTree: Prevent selection of a node from being removed when expanding a node
  $sitemap.on 'tree.opening tree.open', (event) ->
    $sitemap.tree('addToSelection', event.node) if event.node.active

  # Move a node inside, before or after another one
  $sitemap.on 'tree.move', (event) ->
    event.preventDefault()
    moveInfo = event.move_info
    movedNode = moveInfo.moved_node
    targetNode = moveInfo.target_node
    if !targetNode.root or (targetNode.root and moveInfo.position == 'inside')
      jQuery.ajax
        url: movedNode.move_url
        type: 'post'
        data: { _method: 'patch', to: targetNode.id, position: moveInfo.position }
        success: ->
          selectedNode = $sitemap.tree('getSelectedNode')
          moveInfo.do_move()
          Turbolinks.visit(selectedNode.url) if movedNode == selectedNode
        error: (xhr) ->
          alert xhr.responseText


cachedScrollTop = null


# Fix for Turbolinks: Destroy all events before page is loaded with new content
# Save scroll position to restore on page:load

$(document)

  .on 'page:receive', ->
    $sitemap = $(SITEMAP_SELECTOR)
    if $sitemap.exists()
      cachedScrollTop = $sitemap.scrollTop()
      $sitemap.slimScroll(destroy: true)
      _.each ['load_data', 'click', 'select', 'open', 'opening', 'move'], (eventName) ->
        $sitemap.off("tree.#{eventName}")
      $sitemap.tree('destroy')

  .on 'page:load', ->
    $sitemap = $(SITEMAP_SELECTOR)
    $sitemap.slimScroll(scrollTo: cachedScrollTop) if $sitemap.exists() and cachedScrollTop 


# Disable keyboard navigation in sitemap if a modal is active

$(document)

  .on 'show.bs.modal', ->
    $(SITEMAP_SELECTOR).tree 'setOption', 'keyboardSupport', false
    true

  .on 'hidden.bs.modal', ->
    $(SITEMAP_SELECTOR).tree 'setOption', 'keyboardSupport', true
    true
