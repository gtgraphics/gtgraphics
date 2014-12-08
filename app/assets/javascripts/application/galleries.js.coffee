$(document).ready ->

  $gallery = $('#gallery').css(opacity: 0)

  $gallery.imagesLoaded ->
    $gallery.masonry
      itemSelector: '.brick'
      columnWidth: (containerWidth) ->
        Math.round(containerWidth / 3)
      gutter: 20
      transitionDuration: '200ms'
    $gallery.animate(opacity: 1)


  $gallery.infinitescroll
    navSelector: '#pagination' # selector for the paged navigation
    nextSelector: '#pagination #next_page' # selector for the NEXT link (to page 2)
    itemSelector: '.brick' # selector for all items you'll retrieve
    maxPage: $gallery.data('totalPages')
    loading: { }
    
  # trigger Masonry as a callback
  , (newElements) ->
    
    # hide new items while they are loading
    $newElems = $(newElements).css(opacity: 0)
    
    # ensure that images load before adding to masonry layout
    $newElems.imagesLoaded ->
      
      # show elems now they're ready
      $newElems.animate(opacity: 1)
      $gallery.masonry('appended', $newElems, true)
