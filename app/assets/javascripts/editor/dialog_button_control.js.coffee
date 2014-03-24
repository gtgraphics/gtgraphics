class @Editor.Control.DialogButtonControl extends @Editor.Control.ButtonControl
  executeCommand: (callback) ->
    # TODO Wait for modal to dispose and then trigger callback

    dialogUrl = @getDialogUrl()
    console.log dialogUrl

    $body = $('body')
    jQuery.get(dialogUrl).fail(callback).done (html) =>
      $modal = $(html).appendTo($body).prepare()
      $modal.data('toolbar', @toolbar)
      $modal.modal('show')

      $forms = $modal.find('.editor-form')
      $forms.submit (event) ->
        event.preventDefault()

        $form = $(@)
        formUrl = $form.attr('action')
        method = $form.attr('method')
        params = $form.serializeArray()
        
        console.log method
        console.log params

        jQuery.ajax
          url: formUrl
          type: method
          data: params
          dataType: 'html'
          success: (html) ->
            console.log html
          error: (xhr, textStatus, errorThrown) ->
            console.error xhr
            console.error textStatus
            console.error errorThrown

      $modal.on 'hidden.bs.modal', ->
        $modal.remove()
        callback()

  getDialogUrl: ->
    console.error 'no dialog URL defined'

  onExecute: ->
    # TODO Create and show modal and load content

  onExecuted: ->
    # TODO Hide modal
    #@$modal = null

    console.log 'finished!!!'