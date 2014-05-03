class @PageEditor

  @defaults =
    selector: '.region'

  @open = (pageId, locale) ->
    console.log pageId
    console.log locale

  constructor: (options = {}) ->
    @options = jQuery.extend({}, PageEditor.defaults, options)
   

    $(@options.selector).each ->
      $region = $(@)
      $region.attr('contenteditable', true)
      $region.attr('designmode', 'on')