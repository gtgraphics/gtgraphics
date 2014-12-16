# class @Lightbox
#   @DOM_ID = 'lightbox'
#   @OPENED_CLASS = 'opened'
#   @ACTIVE_BODY_CLASS = 'lightbox-active'

#   @getInstance = ->
#     @instance ||= new Lightbox

#   @open = (url) ->
#     @getInstance().open(url)

#   @close = ->
#     @getInstance().close()

#   constructor: ->
#     @$body = $('body')
#     @$lightbox = $("##{Lightbox.DOM_ID}")
#     unless @$lightbox.length
#       @$lightbox = $('<div />', id: Lightbox.DOM_ID)
#       @$body.append(@$lightbox)
#     @$lightbox.hide()

#   open: (url) ->
#     jQuery.error 'URL is empty' unless url
#     return Turbolinks.visit(url) unless Turbolinks.supported


#     @opened = true
#     @currentUrl = url
#     @$lightbox.show().addClass(Lightbox.OPENED_CLASS)
#     @$body.addClass(Lightbox.ACTIVE_BODY_CLASS)

#     history.pushState(url, url, url)

#     @$lightbox.load url, ->
#       console.log 'loaded'
    

#   close: ->
#     return Turbolinks.visit(@previousUrl) unless Turbolinks.supported

#     @opened = false
#     @currentUrl = null
#     @$lightbox.hide().removeClass(Lightbox.OPENED_CLASS)
#     @$body.removeClass(Lightbox.ACTIVE_BODY_CLASS)

# $(document).on 'click', '[data-open="lightbox"]', (event) ->
#   event.preventDefault()
#   $link = $(@)
#   url = $link.data('url') || $link.attr('href')
#   Lightbox.open(url)
#   console.log Lightbox.getInstance()

# $(document).on 'click', '[data-close="lightbox"]', (event) ->
#   Lightbox.close()
#   console.log Lightbox.getInstance()
