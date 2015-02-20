$(document).ready ->
   $('.submenu-item, .icon-menu-item').each ->
    $submenuItem = $(@)
    if $submenuItem.find('img').length
      $submenuItem.css(opacity: 0)
      $submenuItem.allImagesLoaded ->
        $submenuItem.transition(opacity: 1, duration: 500)
