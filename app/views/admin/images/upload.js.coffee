$image = $("<%= escape_javascript render(@image) %>")

$('#images').removeClass('hidden').find('tbody').prepend($image)
$image.prepare().hide().fadeIn('fast')

$('#images_empty_hint').addClass('hidden')
