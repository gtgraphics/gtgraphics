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