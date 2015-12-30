setupCharts = ->
  $('[data-provides="disk-usage"]').each ->
    $container = $(@)

    captions = {
      title: $container.data('captionTitle') || '',
      value: $container.data('captionValue') || 'Value',
      bytesUsed: $container.data('captionBytesused') || 'Bytes Used',
      bytesFree: $container.data('captionBytesfree') || 'Bytes Free'
    }

    target = $($container.data('target')).get(0)

    $bytesUsed = $container.find('[data-contains="bytes-used"]')
    $bytesFree = $container.find('[data-contains="bytes-free"]')
    bytesUsed = $bytesUsed.data('value')
    bytesFree = $bytesFree.data('value')

    results = []
    results.push([captions.title, captions.value])
    results.push([captions.bytesFree, bytesFree])
    results.push([captions.bytesUsed, bytesUsed])

    data = google.visualization.arrayToDataTable(results)

    chart = new google.visualization.PieChart(target)
    chart.draw(data, {})

google.setOnLoadCallback(setupCharts)
$(document).on('page:load', setupCharts)
