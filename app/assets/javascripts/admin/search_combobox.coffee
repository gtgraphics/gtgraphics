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
        header: (context) ->
          "<h3 class='nav-header'>#{I18n.translate('activerecord.models.page.other')}</h3>" unless context.isEmpty
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
        header: (context) ->
          "<h3 class='nav-header'>#{I18n.translate('activerecord.models.image.other')}</h3>" unless context.isEmpty
        suggestion: (context) ->
          Mustache.render("
            <div class='image'>
              <div class='preview'><img src='{{thumbnailAssetUrl}}' alt='{{title}}' class='img-circle' width='45' height='45'></div>
              <div class='title'>{{title}}</div>
              <div class='detail text-muted'>{{humanDimensions}}</div>
            </div>
          ", context)
      }
    },
    {
      name: 'projects'
      displayKey: 'title'
      source: bloodhounds.projects.ttAdapter()
      templates: {
        header: (context) ->
          "<h3 class='nav-header'>#{I18n.translate('activerecord.models.project.other')}</h3>" unless context.isEmpty
        suggestion: (context) ->
          Mustache.render("
            <div class='project'>
              {{#thumbnailAssetUrl}}
              <div class='preview'><img src='{{thumbnailAssetUrl}}' alt='{{title}}' class='img-circle' width='45' height='45'></div>
              {{/thumbnailAssetUrl}}
              <div class='title'>{{title}}</div>
              <div class='detail text-muted'>{{clientName}}</div>
            </div>
          ", context)
      }
    }
  )

  $search.on 'typeahead:selected typeahead:autocompleted', (event, suggestion, dataset) ->
    event.preventDefault()
    Turbolinks.visit suggestion.url

$(document).ready ->
  $('[autofocus].tt-input').focus()