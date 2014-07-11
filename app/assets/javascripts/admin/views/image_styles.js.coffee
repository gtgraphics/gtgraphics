$(document).ready ->
  $input = $('#image_style_upload')
  $input.fileupload
    dataType: 'script'
    dropZone: $('#image_style_upload_dropzone')
    add: (event, data) ->
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
