$(document).ready ->

  # https://github.com/blueimp/jQuery-File-Upload/wiki/API

  $('#image_uploader').fileupload
    dataType: 'script'
    dropzone: $('#dropzone')
    add: (e, data) ->
      console.log data       
    progress: (e, data) ->
      console.log data

