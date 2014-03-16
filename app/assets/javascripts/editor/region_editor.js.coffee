class @RegionEditor

  @defaults =
    selector: '.region'

  constructor: (options = {}) ->
    @options = jQuery.extend({}, RegionEditor.defaults, options)

    

    $(@options.selector).each ->
      $region = $(@)
      $region.attr('contenteditable', true)
      $region.attr('designmode', 'on')