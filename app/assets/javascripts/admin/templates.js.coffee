queryFileNameState = ($type, $fileName) ->
  type = $type.val()
  $fileName.prop('disabled', type == '')

$(document).ready ->
  $type = $('#template_type')
  #$fileName = $('#template_file_name')
  $fileNameContainer = $('#template_file_name_container')

  #queryFileNameState($type, $fileName)

  $type.change ->
    #queryFileNameState($type, $fileName)

    templateType = $type.val()

    if templateType == ''
      $fileNameContainer.empty()
    else
      $fileName = $('#template_file_name')
      $fileName.prop('disabled', true)

      jQuery.ajax
        url: '/admin/templates/unassigned_files_fields'
        data: { template_type: templateType }
        dataType: 'html'
        success: (html) ->
          $fileNameContainer.html(html)
        complete: ->
          $fileName.prop('disabled', false)