class @Cropper
  constructor: ($container) ->
    @image = $('.img-croppable', $container)
    @originalWidth = @image.data('originalWidth')
    @originalHeight = @image.data('originalHeight')
    @inputs = {
      cropX: $('.crop-x', $container)
      cropY: $('.crop-y', $container)
      cropWidth: $('.crop-width', $container)
      cropHeight: $('.crop-height', $container)
      cropAspectRatio: $('.crop-aspect-ratio', $container)
      resizeWidth: $('.resize-width', $container)
      resizeHeight: $('.resize-height', $container)
      resizeAspectRatio: $('.resize-aspect-ratio', $container)      
    }

    @initImageEvents()

  initInputEvents: ->
    # Crop
    @applyCropInputEvents @inputs.cropX
    @applyCropInputEvents @inputs.cropY
    @applyCropInputEvents @inputs.cropWidth
    @applyCropInputEvents @inputs.cropHeight, =>
      if @inputs.cropAspectRatio.prop('checked')
        @setCropWidth(@cropWidthAspectRatio * @getCropHeight())

    refreshCropAspectRatioState = =>
      if @inputs.cropAspectRatio.prop('checked')
        @cropWidthAspectRatio = @inputs.cropWidth.val() / @inputs.cropHeight.val()
        @cropHeightAspectRatio = @inputs.cropHeight.val() / @inputs.cropWidth.val()
      else
        @cropWidthAspectRatio = null
        @cropHeightAspectRatio = null
      @cropper.setOptions(aspectRatio: @cropWidthAspectRatio)

    refreshCropAspectRatioState()
    @inputs.cropAspectRatio.change =>
      refreshCropAspectRatioState()

    # TODO Resize Aspect Ratio
    # TODO Resize Inputs

  initImageEvents: ->
    @setCropAreaExplicitly = false
    @cropper = undefined
    @image.load =>
      @cropper = $.Jcrop(@image, {
        trueSize: [@originalWidth, @originalHeight]
        allowSelect: false
        onChange: (coordinates) =>
          @cropArea = @convertToCropArea(@cropper.tellSelect()) unless @cropArea
          newCropArea = @convertToCropArea(coordinates)
          if @cropArea
            @cropAreaChanged = {
              x: (newCropArea.x - @cropArea.x) != 0.0
              y: (newCropArea.y - @cropArea.y) != 0.0
              width: (newCropArea.width - @cropArea.width) != 0.0
              height: (newCropArea.height - @cropArea.height) != 0.0
            }
          else
            @cropAreaChanged = {
              x: true
              y: true
              width: true
              height: true
            }
          @cropArea = newCropArea
          unless @setCropAreaExplicitly
            @setCropX(@cropArea.x) if @cropAreaChanged.x
            @setCropY(@cropArea.y) if @cropAreaChanged.y
            @setCropWidth(@cropArea.width) if @cropAreaChanged.width
            @setCropHeight(@cropArea.height) if @cropAreaChanged.height
          @setCropAreaExplicitly = false
      })
      @initInputEvents()
      @updateCropArea()

  convertToCropArea: (coordinates) ->
    {
      x: coordinates.x
      y: coordinates.y
      width: coordinates.x2 - coordinates.x
      height: coordinates.y2 - coordinates.y
    }

  getCropAspectRatio: ->
    @getCropWidth() / @getCropHeight()

  getCropX: ->
    parseValue(@inputs.cropX.val())

  getCropY: ->
    parseValue(@inputs.cropY.val())

  getCropWidth: ->
    parseValue(@inputs.cropWidth.val())

  getCropHeight: ->
    parseValue(@inputs.cropHeight.val())

  getMaxCropWidth: ->
    @originalWidth - @getCropX()

  getMaxCropHeight: ->
    @originalHeight - @getCropY()

  setCropX: (x) ->
    x = Math.round(x)
    @inputs.cropX.val(x).attr('max', @getMaxCropWidth())

  setCropY: (y) ->
    y = Math.round(y)
    @inputs.cropY.val(y).attr('max', @getMaxCropHeight())

  setCropWidth: (width) ->
    width = Math.round(width)
    width = @getMaxCropWidth() if width > @getMaxCropWidth()
    @inputs.cropWidth.val(width)

  setCropHeight: (height) ->
    height = Math.round(height)
    height = @getMaxCropHeight() if height > @getMaxCropHeight()
    @inputs.cropHeight.val(height)

  setCropArea: (x, y, width, height) ->
    @setCropX(x)
    @setCropY(y)
    @setCropWidth(width)
    @setCropHeight(height)

  updateCropArea: ->
    @cropper.setSelect([@getCropX(), @getCropY(), @getCropX() + @getCropWidth(), @getCropY() + @getCropHeight()])

  isValidCropArea: ->
    cropX = @getCropX()
    cropY = @getCropY()
    cropWidth = @getCropWidth()
    cropHeight = @getCropHeight()
    cropXValid = cropX >= 0 and cropX <= @originalWidth
    cropYValid = cropY >= 0 and cropY <= @originalHeight
    cropWidthValid = cropWidth > 0 and cropWidth <= (@originalWidth - cropX)
    cropHeightValid = cropHeight > 0 and cropHeight <= (@originalHeight - cropY)
    cropXValid and cropYValid and cropWidthValid and cropHeightValid

  # Helpers

  applyCropInputEvents: ($input, callback) ->
    value = $input.val()
    $input.data('prevValue', value)

    $input.on 'textchange blur', =>
      value = $input.val()
      if presentString(value)
        if $input.data('prevValue') != value
          @setCropAreaExplicitly = true
          callback() if callback
          @updateCropArea()
        $input.data('prevValue', value)

  emptyString = (value) ->
    jQuery.trim(value) == ''

  presentString = (value) ->
    !emptyString(value)

  parseValue = (value) ->
    value = parseInt(value)
    value = 0 if isNaN(value)
    value


$(document).ready ->

  @cropper = new Cropper($('#crop_fields'))

  # cropper = new Cropper($image, cropX: $cropX, cropY: $cropY, cropWidth: $cropWidth, cropHeight: $cropHeight, resizeWidth: $resizeWidth, resizeHeight: $resizeHeight)

