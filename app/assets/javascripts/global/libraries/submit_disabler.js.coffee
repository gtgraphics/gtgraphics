$doc = $(document)

$doc.on 'submit', "form:not([data-remote='true'])", ->
  $(@).find(':submit').prop('disabled', true)

$doc.on 'ajax:beforeSend', "form[data-remote='true']", ->
  $(@).find(':submit').prop('disabled', true)

$doc.on 'ajax:complete', "form[data-remote='true']", ->
  $(@).find(':submit').prop('disabled', false)