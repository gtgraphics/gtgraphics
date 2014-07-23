$image = $("<%= escape_javascript render(@attachment) %>")

$('#attachments').removeClass('hidden').find('tbody').prepend($image)
$image.prepare().hide().fadeIn('fast')

$('#attachments_empty_hint').addClass('hidden')
