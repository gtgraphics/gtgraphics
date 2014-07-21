$(document).ready ->
  $input = $('#image_upload')
  $input.fileupload
    dataType: 'script'
    dropZone: $('#image_upload_dropzone')
    add: (event, data) ->
      acceptFileTypes = /^image\/(gif|jpe?g|png)$/i
      errors = []
      file = data.originalFiles[0]
      if file.type.length and !acceptFileTypes.test(file.type)
        alert errors.join('\n')
      else
        data.submit()
    done: (event, data) ->

    progressall: (event, data) ->
      progress = Math.round(data.loaded / data.total * 100)
      if progress == 100
        $('body').removeClass('busy')
        caption = ''
      else
        $('body').addClass('busy')
        caption = progress.toString()
      $('#loader .progress-percentage').text(caption)
