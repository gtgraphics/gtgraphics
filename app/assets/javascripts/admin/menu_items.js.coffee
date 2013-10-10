$(document).on 'change', "#menu_item_record_type", ->
  $select = $(this)
  $recordTypeFields = $('#record_type_fields')

  recordType = $select.val()
  url = $select.data("url")

  if recordType is ""
    $recordTypeFields.empty().hide()
  else
    $select.prop('disabled', true)
    $.ajax
      url: url
      dataType: 'html'
      data: { record_type: recordType }
      success: (html) ->
        $recordTypeFields.html(html).show()
      error: ->
        $recordTypeFields.empty().hide()
      complete: ->
        $select.prop('disabled', false)