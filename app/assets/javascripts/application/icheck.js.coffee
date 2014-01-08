CHECKBOX_DETERMINATE_TEMPLATE = '<span class="check-indicator"><i class="fa fa-check"></i></span>'
CHECKBOX_INDETERMINATE_TEMPLATE = '<span class="check-indeterminate-indicator"><i class="fa fa-minus"></i></span>'
RADIO_TEMPLATE = '<span class="radio-indicator"><i class="fa fa-circle"></i></span>'

$.prepare ->
  $(':checkbox, :radio', @).iCheck(
    checkboxClass: 'checkbox-container btn btn-default'
    radioClass: 'radio-container btn btn-default'
    insert: CHECKBOX_DETERMINATE_TEMPLATE + CHECKBOX_INDETERMINATE_TEMPLATE + RADIO_TEMPLATE
    increaseArea: '30%'
  )