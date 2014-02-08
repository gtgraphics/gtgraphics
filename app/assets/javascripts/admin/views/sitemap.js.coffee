SITEMAP_SELECTOR = '#sitemap'

$(document).ready ->
  $('#page_content').affix
    offset:
      top: ->
        $('.gtg-admin-toolbar').offset().top - $('#navigation').outerHeight()

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
      unless node.root
        $dragHandle = $('<div />', class: 'jqtree-handle')
        $dragHandle.html('<i class="fa fa-bars"></i>')
        $listItem.find('.jqtree-title').after($dragHandle)

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
  $sitemap.tree('addToSelection', selectedNode)

  $sitemap.on 'tree.click', (event) ->
    event.preventDefault() if $sitemap.tree('isNodeSelected', event.node)

  $sitemap.on 'tree.select', (event) ->
    console.log 'select'
    if selectedNode = event.node
      Turbolinks.visit(selectedNode.url)

  selectedNodeForOpening = null

  $sitemap.on 'tree.opening', ->
    selectedNodeForOpening = $sitemap.tree('getSelectedNode')

  $sitemap.on 'tree.open', (event) ->
    if selectedNodeForOpening
      $sitemap.tree('addToSelection', selectedNodeForOpening)
      selectedNodeForOpening = null

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

$(document).on 'page:load', ->
  $sitemap = $(SITEMAP_SELECTOR)
  if $sitemap.exists()
    # Scroll to selected node
    selectedNode = $sitemap.tree('getSelectedNode')
    $selectedNode = $(selectedNode.element)
    offset = $('#navigation').outerHeight() + $('#toolbar').outerHeight() + 20 + 2 * 37
    scrollX = $selectedNode.offset().top - offset
    $(document).scrollTop(scrollX)

$(document).on 'page:receive', ->
  $sitemap = $(SITEMAP_SELECTOR)
  if $sitemap.exists()
    # Turbolinks Fix to destroy all events before page is loaded with new content
    _.each ['load_data', 'click', 'select', 'open', 'opening', 'move'], (eventName) ->
      $sitemap.off("tree.#{eventName}")
    $sitemap.tree('destroy')
