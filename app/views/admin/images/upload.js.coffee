$image = $("<%= escape_javascript render(@image) %>")
$('#images').prepend($image)
$image.prepare()
