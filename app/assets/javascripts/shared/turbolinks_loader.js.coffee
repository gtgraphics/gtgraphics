showLoader = ->
  $('body').addClass('loading')
  $('#loader').fadeIn('fast')

hideLoader = ->
  $('body').removeClass('loading')
  $('#loader').fadeOut('fast')

$(document)
  .on 'page:fetch', ->
    showLoader()

  .on 'page:receive page:restore', ->
    hideLoader()

  .on 'submit', "form:not([data-remote=true])", ->
    showLoader()

  .on 'ajax:beforeSend', "form[data-remote=true]", ->
    showLoader()

  .on 'ajax:complete', "form[data-remote=true]", ->
    hideLoader()

  .ajaxStart ->
    showLoader()

  .ajaxStop ->
    hideLoader()

# Tooltips Fix
$(document).on 'page:change', ->
  $('.tooltip').remove()
