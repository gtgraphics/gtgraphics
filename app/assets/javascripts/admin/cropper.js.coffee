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
    @applyInputEvents @inputs.cropX
    @applyInputEvents @inputs.cropY

    @applyInputEvents @inputs.cropWidth, =>
      @adjustResizeWidthToCropWidth()
      if @inputs.cropAspectRatio.prop('checked')
        @setCropWidth(@cropHeightAspectRatio * @getCropWidth())

    @applyInputEvents @inputs.cropHeight, =>
      @adjustResizeHeightToCropHeight()
      if @inputs.cropAspectRatio.prop('checked')
        @setCropWidth(@cropWidthAspectRatio * @getCropHeight())

    @refreshCropAspectRatioState()
    @inputs.cropAspectRatio.change =>
      @refreshCropAspectRatioState()

    # Resize
    @applyInputEvents @inputs.resizeWidth, =>
      if @inputs.resizeAspectRatio.prop('checked')
        @setResizeHeight(@resizeHeightAspectRatio * @getResizeWidth())
    @applyInputEvents @inputs.resizeHeight, =>
      if @inputs.resizeAspectRatio.prop('checked')
        @setResizeWidth(@resizeWidthAspectRatio * @getResizeHeight())
    
    @refreshResizeAspectRatioState()
    @inputs.resizeAspectRatio.change =>
      @refreshResizeAspectRatioState()

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

  getResizeWidth: ->
    parseValue(@inputs.resizeWidth.val())

  getResizeHeight: ->
    parseValue(@inputs.resizeHeight.val())

  setCropX: (x) ->
    @inputs.cropX.val(Math.round(x)).attr('max', @getMaxCropWidth())

  setCropY: (y) ->
    @inputs.cropY.val(Math.round(y)).attr('max', @getMaxCropHeight())

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

  setResizeWidth: (width) ->
    @inputs.resizeWidth.val(Math.round(width))

  setResizeHeight: (height) ->
    @inputs.resizeHeight.val(Math.round(height))

  updateCropArea: ->
    @cropper.setSelect([
      @getCropX(),
      @getCropY(),
      @getCropX() + @getCropWidth(),
      @getCropY() + @getCropHeight()
    ])

  # Helpers

  adjustResizeWidthToCropWidth: ->
    @setResizeWidth(@inputs.cropWidth.val()) # FIXME

  adjustResizeHeightToCropHeight: ->
    # TODO Height has already the new value here... thats wrong
    cropHeight = @getCropHeight()
    resizeHeight = @getResizeHeight()
    ratio = resizeHeight / cropHeight
    console.log ratio
    @setResizeHeight(cropHeight) # FIXME

  applyInputEvents: ($input, callback) ->
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

  refreshCropAspectRatioState: ->
    if @inputs.cropAspectRatio.prop('checked')
      @cropWidthAspectRatio = @inputs.cropWidth.val() / @inputs.cropHeight.val()
      @cropHeightAspectRatio = @inputs.cropHeight.val() / @inputs.cropWidth.val()
    else
      @cropWidthAspectRatio = null
      @cropHeightAspectRatio = null
    @cropper.setOptions(aspectRatio: @cropWidthAspectRatio)

  refreshResizeAspectRatioState: ->
    if @inputs.resizeAspectRatio.prop('checked')
      @resizeWidthAspectRatio = @inputs.resizeWidth.val() / @inputs.resizeHeight.val()
      @resizeHeightAspectRatio = @inputs.resizeHeight.val() / @inputs.resizeWidth.val()
    else
      @resizeWidthAspectRatio = null
      @resizeHeightAspectRatio = null


$(document).ready ->

  @cropper = new Cropper($('#crop_fields'))

  # cropper = new Cropper($image, cropX: $cropX, cropY: $cropY, cropWidth: $cropWidth, cropHeight: $cropHeight, resizeWidth: $resizeWidth, resizeHeight: $resizeHeight)

