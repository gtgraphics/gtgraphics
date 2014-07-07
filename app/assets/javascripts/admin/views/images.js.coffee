# TODO 
# Implement DND File Uploader
# http://stackoverflow.com/questions/15410265/file-upload-progress-bar-with-jquery

refreshProgressBar = (progress = 0) ->
  $progress = $('#progress')
  if progress == 0
    $progress.hide()
  else if progress == 100
    setTimeout ->
      $progress.hide()
    , 1500 # wait a second before hiding
  else
    $progress.show()
    progress = progress.toString()
    $('.progress-bar', $progress).css(width: "#{progress}%").attr('aria-valuenow', progress)
    $('.percentage', $progress).text("#{progress}%")



$(document).ready ->
  refreshProgressBar()

  $input = $('#image_upload')
  $input.fileupload
    dataType: 'script'
    add: (event, data) ->
      data.submit()
    done: (event, data) ->
      console.log 'done:'
      console.log data
    progressall: (event, data) ->
      progress = Math.round(data.loaded / data.total * 100)
      refreshProgressBar(progress)
