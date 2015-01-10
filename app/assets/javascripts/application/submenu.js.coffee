$(document).ready ->
   $('.submenu-item').each ->
    $submenuItem = $(@)
    if $submenuItem.find('img').length
      $submenuItem.hide().css(opacity: 0)
      $submenuItem.allImagesLoaded ->
        $submenuItem.show().transition(opacity: 1, duration: 500)
