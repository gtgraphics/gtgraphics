$(document).ready ->

  $search = $('#search')

  value = $search.val()

  bloodhounds = {}
  sources = $search.data('from')
  _(sources).each (url, source) ->
    bloodhound = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('title')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote: "#{url}?query=%QUERY"
    )
    bloodhound.initialize()
    bloodhounds[source] = bloodhound


  $search.typeahead({ highlight: true },
    {
      name: 'pages'
      displayKey: 'title'
      source: bloodhounds.pages.ttAdapter()
      templates: {
        header: '<h3 class="nav-header">Pages</h3>'
        suggestion: (context) ->
          Mustache.render('
            <div class="title">{{title}}</div>
            <div class="path text-muted">{{path}}</div>
          ', context)
      }
    },
    {
      name: 'images'
      displayKey: 'title'
      source: bloodhounds.images.ttAdapter()
      templates: {
        header: '
          <div class="divider"></div>
          <h3 class="nav-header">Images</h3>
        '
        suggestion: (context) ->
          Mustache.render('
            <div class="clearfix">
              <div class="pull-left"><img src="{{thumbnailAssetUrl}}" alt="{{title}}" class="img-circle" width="45" height="45"></div>
              <div class="title">{{title}}</div>
              <div class="format text-muted">{{humanDimensions}}</div>
            </div>
          ', context)
      }
    }
  )

  $search.on 'typeahead:selected typeahead:autocompleted', (event, suggestion, dataset) ->
    event.preventDefault()
    Turbolinks.visit suggestion.url

$(document).ready ->
  $('[autofocus].tt-input').focus()