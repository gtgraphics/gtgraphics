class @PageEditor

  @defaults =
    selector: '.region'

  constructor: (options = {}) ->
    @options = jQuery.extend({}, PageEditor.defaults, options)
   

    $(@options.selector).each ->
      $region = $(@)
      $region.attr('contenteditable', true)
      $region.attr('designmode', 'on')