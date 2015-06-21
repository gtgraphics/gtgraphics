MODAL_SELECTOR = '#modal'

$.showModal = (html) ->
  $(MODAL_SELECTOR).remove()
  $('body').append(html)
  $modal = $(MODAL_SELECTOR)
  jQuery.error('No modal element found') unless $modal.length
  $modal.modal('show')
  $(document).click() # fix to hide dropdown menu
  $modal

$.updateModalForm = (html) ->
  $modal = $(MODAL_SELECTOR)
  $('form', $modal).replaceWith(html)
  $('form', $modal).prepare()

$.hideModal = ->
  $(MODAL_SELECTOR).modal('hide')

$(document).on 'hidden.bs.modal', ->
  $(MODAL_SELECTOR).remove()

$(document).on 'show.bs.modal', ->
  $(MODAL_SELECTOR).prepare()
