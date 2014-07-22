queryFileNameState = ($type, $fileName) ->
  type = $type.val()
  $fileName.prop('disabled', type == '')

$(document).ready ->
  $type = $('#template_type')
  $fileNameContainer = $('#template_file_name_container')

  $type.change ->
    templateType = $type.val()
    if templateType is ''
      $fileNameContainer.empty()
    else
      $fileName = $('#template_file_name')
      $fileName.prop('disabled', true)
      jQuery.ajax
        url: '/admin/templates/files_fields'
        data: { template_type: templateType }
        dataType: 'html'
        success: (html) ->
          $fileNameContainer.html(html)
        complete: ->
          $fileName.prop('disabled', false)
