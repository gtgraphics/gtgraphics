class @Editor.Control.DialogButtonControl extends @Editor.Control.ButtonControl
  executeCommand: (callback) ->
    control = @
    jQuery.get(@getDialogUrl()).fail(callback).done (html) =>
      $modal = $(html).appendTo($('body')).prepare()
      $modal.data('toolbar', @toolbar)
      $modal.modal('show')

      $modal.on 'hidden.bs.modal', ->
        $modal.remove()
        callback()

      $modal.on 'submit', '.editor-form', (event) ->
        event.preventDefault()
        $form = $(@)
        formUrl = $form.attr('action')
        method = $form.attr('method')
        params = $form.serializeArray()
        jQuery.ajax
          url: formUrl
          type: method
          data: params
          dataType: 'html'
          success: (html) ->
            console.log html
            $modal.modal('hide')
            editor = control.getActiveEditor()
            editor.$region.append(html) if editor.isRendered() # TODO
          error: (xhr) ->
            # Validation failed, replace form to show validation messages
            if xhr.status == 422
              $newForm = $(xhr.responseText)
              $form.replaceWith($newForm)
              $newForm.prepare()

  getDialogUrl: ->
    console.error 'no dialog URL defined'

  onExecute: ->
    @$control.prop('disabled', true) if @isRendered()

  onExecuted: ->
    @$control.prop('disabled', false) if @isRendered()