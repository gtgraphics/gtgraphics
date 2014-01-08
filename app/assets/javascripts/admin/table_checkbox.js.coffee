# Checkbox Table

TABLE_SELECTOR = '.table'
SINGLE_CHECKBOX_SELECTOR = '.table-checkbox'
GLOBAL_CHECKBOX_SELECTOR = '.table-checkbox-all'


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


$(document).ready ->

  $tables = $(TABLE_SELECTOR)
  
    .on 'ifChanged', GLOBAL_CHECKBOX_SELECTOR, ->
      $toggler = $(@)
      $table = $toggler.closest(TABLE_SELECTOR)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)
      if $toggler.prop('indeterminate')
        $toggler.attr('indeterminate', false).prop('checked', true)
      else
        if allCheckboxesChecked($checkboxes)
          $checkboxes.prop('checked', false)
        else
          $checkboxes.prop('checked', true)
      $checkboxes.iCheck('update')
      $toggler.iCheck('update')
      $table.trigger('toggled', [checkStatus($checkboxes)])

    .on 'ifChanged', SINGLE_CHECKBOX_SELECTOR, ->
      $checkbox = $(@)
      $table = $checkbox.closest(TABLE_SELECTOR)
      $toggler = $table.find(GLOBAL_CHECKBOX_SELECTOR)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)

      $checkbox.iCheck('update')
      
      checked = !allCheckboxesChecked($checkboxes)
      #$toggler.prop('checked', checked).iCheck('update')
      #$checkboxes.prop('checked', checked)

      cs = checkStatus($checkboxes)
      switch cs
        when 'all'
          $toggler.attr('indeterminate', false).prop('checked', true)
        when 'some'
          $toggler.attr('indeterminate', true).prop('checked', false)
        else
          $toggler.attr('indeterminate', false).prop('checked', false)

      $toggler.iCheck('update')
      $checkboxes.iCheck('update')

      $table.trigger('toggled', [cs])

    .each ->
      $table = $(@)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)
      $table.trigger('toggled', [checkStatus($checkboxes)])

# Batch Buttons

BATCH_CONTROLS_SELECTOR = '.batch-control, .batch-controls'
DELAY = 100

$(document).ready ->
  $(BATCH_CONTROLS_SELECTOR).hide()
 
$(document).on 'toggled', '.table', (event, checkStatus) ->
  $batchBtn = $(@).closest('form').find(BATCH_CONTROLS_SELECTOR)
  if checkStatus == 'none'
    $batchBtn.fadeOut DELAY
  else
    $batchBtn.fadeIn DELAY

  #$(@).closest('form').find('.batch-btn').prop('disabled', checkStatus == 'none')