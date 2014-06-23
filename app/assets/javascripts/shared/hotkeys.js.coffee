MODIFIER_SEPARATOR_CHAR = '+'

SPECIAL_KEYS = {
  "backspace": 8
  "tab": 9
  "return": 10
  "return": 13
  "shift": 16
  "ctrl": 17
  "alt": 18
  "pause": 19,
  "capslock": 20
  "esc": 27
  "space": 32
  "pageup": 33
  "pagedown": 34
  "end": 35
  "home": 36,
  "left": 37
  "up": 38
  "right": 39
  "down": 40
  "insert": 45
  "del": 46
  ";": 59
  "=": 61
  "0": 96
  "1": 97
  "2": 98
  "3": 99
  "4": 100
  "5": 101
  "6": 102
  "7": 103
  "8": 104
  "9": 105
  "*": 106
  "+": 107
  "-": 109
  ".": 110
  "/": 111
  "f1": 112
  "f2": 113
  "f3": 114
  "f4": 115
  "f5": 116
  "f6": 117
  "f7": 118
  "f8": 119
  "f9": 120
  "f10": 121
  "f11": 122
  "f12": 123
  "numlock": 144
  "scroll": 145
  "-": 173
  ";": 186
  "=": 187
  ",": 188
  "-": 189
  ".": 190
  "/": 191
  "`": 192
  "[": 219
  "\\": 220
  "]": 221
  "'": 222
}

$(document).on 'keyup', (event) ->
  $('[data-hotkey]').each ->
    $element = $(@)

    keys = $element.data('hotkey').toLowerCase().split(MODIFIER_SEPARATOR_CHAR)
    key = keys[keys.length - 1]
    modifiers = keys.slice(0, keys.length - 1)

    if key.length == 1 and event.which == key.toUpperCase().charCodeAt(0)
      pressed = true
    else
      pressed = event.which == SPECIAL_KEYS[key]

    jQuery.each ['ctrl', 'alt', 'shift', 'meta'], (index, modifier) ->
      if jQuery.inArray(modifier, modifiers) >= 0
        pressed = pressed && event["#{modifier}Key"]

    if pressed
      $element.click()
      return false
    else
      return true
