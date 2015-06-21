class @Editor.Control.DialogButtonControl extends @Editor.Control.ButtonControl
  executeCommand: (callback, context = {}) ->
    control = @

    # Determine if the selected element is a link, if yes open the edit hyperlink modal
    unless context.element?
      editor = @getActiveEditor()
      $element = @getElementFromSelection()
      if $element? and $element.any()
        # existing html node
        editor.setSelectionAroundNode($element.get(0))
        context.element = $element
        context.params = @extractContextParams(editor, $element)
      else 
        # text node
        context.params = @extractContextParams(editor, editor.getSelectedHtml())

    jQuery.get(@getDialogUrl(), context.params || {}).fail(callback).done (html) =>
      $modal = $(html).appendTo($('body')) #.prepare() # 
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
            $modal.modal('hide')
            editor = control.getActiveEditor()
            if editor.isRendered()
              if context.element
                $html = $(html).replaceAll(context.element)
                firstChild = $html.first().get(0)
                lastChild = $html.last().get(0)
                editor.setSelectionAroundNodes(firstChild, lastChild)
              else
                editor.insertHtml(html)

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

  getElementFromSelection: ->
    console.warn 'getElementFromSelection() has not been implemented'

  extractContextParams: ->
    console.warn 'extractContextParams() has not been implemented'
    {}