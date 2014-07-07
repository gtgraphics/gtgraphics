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
  
    .on 'click', 'tr', (event) ->
      if $(event.target).is('td')
        $row = $(@)
        $checkbox = $(SINGLE_CHECKBOX_SELECTOR, $row)
        $checkbox.click() if $checkbox.any()

    #.on 'ifChanged', GLOBAL_CHECKBOX_SELECTOR, ->
    .on 'change', GLOBAL_CHECKBOX_SELECTOR, ->
      $toggler = $(@)
      $table = $toggler.closest(TABLE_SELECTOR)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)
      if $toggler.prop('indeterminate')
        $toggler.prop('indeterminate', false).prop('checked', true)
      else
        if allCheckboxesChecked($checkboxes)
          $checkboxes.prop('checked', false)
        else
          $checkboxes.prop('checked', true)
        $checkboxes.closest('tr').toggleClass('active')
      #$checkboxes.iCheck('update')
      #$toggler.iCheck('update')
      $table.trigger('toggled', [checkStatus($checkboxes)])

    #.on 'ifChanged', SINGLE_CHECKBOX_SELECTOR, ->
    .on 'change', SINGLE_CHECKBOX_SELECTOR, ->
      $checkbox = $(@)
      $table = $checkbox.closest(TABLE_SELECTOR)
      $toggler = $table.find(GLOBAL_CHECKBOX_SELECTOR)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)

      $checkbox.closest('tr').toggleClass('active')

      $checkbox.iCheck('update')
      
      checked = !allCheckboxesChecked($checkboxes)
      #$toggler.prop('checked', checked).iCheck('update')
      #$checkboxes.prop('checked', checked)

      cs = checkStatus($checkboxes)
      switch cs
        when 'all'
          $toggler.prop('indeterminate', false).prop('checked', true)
        when 'some'
          $toggler.prop('indeterminate', true).prop('checked', false)
        else
          $toggler.prop('indeterminate', false).prop('checked', false)

      #$toggler.iCheck('update')
      #$checkboxes.iCheck('update')

      $table.trigger('toggled', [cs])

    .each ->
      $table = $(@)
      $checkboxes = $table.find(SINGLE_CHECKBOX_SELECTOR)
      $table.trigger('toggled', [checkStatus($checkboxes)])

# Batch Buttons

BATCH_CONTROLS_SELECTOR = '.batch-control, .batch-controls'
DEACTIVATABLE_BATCH_CONTROLS_SELECTOR = '.deactivatable-batch-control'
DELAY = 100

$(document).ready ->
  $(BATCH_CONTROLS_SELECTOR).hide()
  $(DEACTIVATABLE_BATCH_CONTROLS_SELECTOR).prop('disabled', true)
 
$(document).on 'toggled', '.table', (event, checkStatus) ->
  $batchBtn = $(@).closest('form').find(BATCH_CONTROLS_SELECTOR)
  $deactivatableBatchBtn = $(@).closest('form').find(DEACTIVATABLE_BATCH_CONTROLS_SELECTOR)

  if checkStatus == 'none'
    $batchBtn.fadeOut DELAY
    $deactivatableBatchBtn.prop('disabled', true)
  else
    $batchBtn.fadeIn DELAY
    $deactivatableBatchBtn.prop('disabled', false)

