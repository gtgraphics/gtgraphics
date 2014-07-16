$image_style = $("<%= escape_javascript render('image_style', image_style: @image_style) %>")

$('#image_styles').find('tbody').append($image_style)
$image_style.prepare().hide().fadeIn('fast')
