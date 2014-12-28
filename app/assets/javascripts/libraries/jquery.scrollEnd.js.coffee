jQuery.fn.scrollEnd = (callback, timeout = 500) ->
  $(this).scroll ->
    $this = $(this)
    clearTimeout $this.data('scrollTimeout')  if $this.data('scrollTimeout')
    $this.data 'scrollTimeout', setTimeout(callback, timeout)
