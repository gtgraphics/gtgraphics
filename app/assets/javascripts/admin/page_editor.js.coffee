initEditor = ($frameContent) ->
  console.log 'loaded'

  $('.region', $frameContent).attr('contenteditable', true)

$(document).ready ->

  $frame = $('#editor_frame').hide()
  $frame.load ->
    $frame.fadeIn('fast')

    # Start here


    $frameContent = $frame.contents()
    frame = $frame.get(0)
    frameDoc = frame.contentDocument
    frameContext = frame.contentWindow

    $('#page_editor_switcher').on 'change', ->
      $select = $(@)
      data = $select.select2('data')

      if frameContext.Turbolinks
        frameContext.Turbolinks.visit(data.editUrl)
      else
        frameDoc.location.href = data.editUrl

    initEditor($frameContent)
    $(frameDoc).on 'page:load', ->
      initEditor($frameContent)

    # Toolbar
    toolbarOptions = {
      controls: [
        ['bold', 'italic', 'underline', 'strikethrough'],
        ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
        ['orderedList', 'unorderedList', 'indent', 'outdent'],
        ['link', 'unlink'],
        ['image']
      ],
      wrapperClass: null
    }
    toolbar = new Editor.Toolbar(null, toolbarOptions)
    $toolbar = toolbar.render()
    $('#editor_controls').append($toolbar)

    # Regions
    # TODO