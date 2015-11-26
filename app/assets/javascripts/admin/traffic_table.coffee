bytesToMBs = (bytes) ->
  Math.round(bytes / Math.pow(1024, 2))

google.load('visualization', '1', packages: ['corechart'])

setupCharts = ->
  $('[data-provides="traffic-table"]').each ->
    $table = $(@)
    $target = $($table.data('target'))
    target = $target.get(0)
    timespan = $table.data('timespan')

    captions = {
      time: $table.data('captionTime'),
      bytesReceived: $table.data('captionBytesReceived'),
      bytesSent: $table.data('captionBytesSent'),
      hAxis: $table.data('captionHAxis'),
      vAxis: $table.data('captionVAxis')
    }

    results = []

    $table.find('[data-time]').each ->
      $row = $(@)
      time = $row.data('time')
      bytesReceived = bytesToMBs($row.data('bytesReceived'))
      bytesSent = bytesToMBs($row.data('bytesSent'))
      results.unshift([time, bytesReceived, bytesSent])

    results.unshift([captions.time, captions.bytesReceived, captions.bytesSent])

    data = google.visualization.arrayToDataTable(results)

    options = {
      hAxis: { title: captions.hAxis },
      vAxis: { title: captions.vAxis }
    }

    chart = new google.visualization.AreaChart(target)
    chart.draw(data, options)

google.setOnLoadCallback(setupCharts)
$(document).on('page:load', setupCharts)
