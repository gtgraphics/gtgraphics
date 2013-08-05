allCheckboxesChecked = ($checkboxes) ->
  checked = true
  $checkboxes.each ->
    return checked = false unless $(@).prop('checked')
  checked

allCheckboxesUnchecked = ($checkboxes) ->
  unchecked = true
  $checkboxes.each ->
    return unchecked = false if $(@).prop('checked')
  unchecked

checkStatus = ($checkboxes) ->
  return 'none' if $checkboxes.length == 0
  if allCheckboxesChecked($checkboxes)
    'all'
  else if allCheckboxesUnchecked($checkboxes)
    'none'
  else
    'some'

TABLE_SELECTOR = '.table'
SINGLE_CHECKBOX_SELECTOR = '.table-checkbox'
GLOBAL_CHECKBOX_SELECTOR = '.table-checkbox-all'
BUTTON_SELECTOR = '.batch-btn'

$(document).ready ->

  $(TABLE_SELECTOR)
  
    .on 'click', GLOBAL_CHECKBOX_SELECTOR, ->
      $toggler = $(@)
      $table = $toggler.closest(TABLE_SELECTOR)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)
      checked = !allCheckboxesChecked($checkboxes)
      $checkboxes.each ->
        $checkbox = $(@)
        prevChecked = $checkbox.prop('checked')
        $checkbox.prop('checked', checked)
        $checkbox.triggerHandler('click') if prevChecked != checked
      $toggler.prop('checked', checked)
      $table.trigger('toggled', [checkStatus($checkboxes)])

    .on 'click', SINGLE_CHECKBOX_SELECTOR, ->
      $checkbox = $(@)
      $table = $checkbox.closest(TABLE_SELECTOR)
      $toggler = $table.find(GLOBAL_CHECKBOX_SELECTOR)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)
      allChecked = allCheckboxesChecked($checkboxes)
      $checkboxes.each ->
        $checkbox = $(@)
        $checkbox.triggerHandler('click')
      
      prevTogglerChecked = $toggler.prop('checked')
      if allChecked
        $toggler.prop('checked', true)
        $toggler.triggerHandler('click')
      else
        #unless $checkbox.prop('checked')
        $toggler.prop('checked', false)
        $toggler.triggerHandler('click')

      $table.trigger('toggled', [checkStatus($checkboxes)])

    .on 'toggled', (event, checkStatus) ->
      $(@).closest('form').find(BUTTON_SELECTOR).prop('disabled', checkStatus == 'none')

    .each ->
      $table = $(@)
      $checkboxes = $table.find('.toggling')
      $table.trigger('toggled', [checkStatus($checkboxes)])