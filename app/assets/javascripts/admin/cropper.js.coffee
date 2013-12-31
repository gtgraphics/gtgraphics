class @Cropper
  constructor: ($container) ->
    @container = $container
    @image = $('.img-croppable', $container)
    @originalWidth = @image.data('originalWidth')
    @originalHeight = @image.data('originalHeight')
    @panels = {
      crop: $('.crop-panel', $container)
      resize: $('.resize-panel', $container)
    }
    @inputs = {
      cropped: $('.crop-flag', $container)
      cropX: $('.crop-x', @panels.crop)
      cropY: $('.crop-y', @panels.crop)
      cropWidth: $('.crop-width', @panels.crop)
      cropHeight: $('.crop-height', @panels.crop)
      cropAspectRatio: $('.crop-aspect-ratio', @panels.crop)
    }
    @resizeable = @panels.resize.length > 0
    if @resizeable
      jQuery.extend @inputs, {
        resized: $('.resize-flag', $container)
        resizeWidth: $('.resize-width', @panels.resize)
        resizeHeight: $('.resize-height', @panels.resize)
        resizeAspectRatio: $('.resize-aspect-ratio', @panels.resize)
        resizeScaleButtons: $('.resize-scale', @panels.resize)
      }

    @applyImageEvents()

  initCropper: ->
    return console.warn 'cropper has already been attached' if @cropper
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

  refreshCroppedState: ->
    enabled = @inputs.cropped.prop('checked')
    $panelBody = @panels.crop.find('.panel-body')
    if enabled
      @panels.crop.removeClass('disabled')
      $panelBody.show()
      @cropper.enable()
    else
      @panels.crop.addClass('disabled')
      $panelBody.hide()
      @cropper.disable()
    $panelBody.find(':input').prop('disabled', !enabled)
    @refreshSubmitButtonState()

  refreshResizedState: ->
    enabled = @inputs.resized.prop('checked')
    $panelBody = @panels.resize.find('.panel-body')
    if enabled
      @panels.resize.removeClass('disabled')
      $panelBody.show()
    else
      @panels.resize.addClass('disabled')
      $panelBody.hide()
    $panelBody.find(':input').prop('disabled', !enabled)
    @refreshSubmitButtonState()

  refreshSubmitButtonState: ->
    disabled = @panels.crop.hasClass('disabled') and @panels.resize.hasClass('disabled')
    $(':submit', @container).prop('disabled', disabled)

  applyInputEvents: ->
    @applyCropInputEvents()
    @applyResizeInputEvents() if @resizeable

  applyCropInputEvents: ->
    if @inputs.cropped.length > 0
      @refreshCroppedState()
      @inputs.cropped.change =>
        @refreshCroppedState()

    @applyInputEvent @inputs.cropX, =>
      @refreshResizeCropRatio()

    @applyInputEvent @inputs.cropY, =>
      @refreshResizeCropRatio()

    @applyInputEvent @inputs.cropWidth, =>
      if @inputs.cropAspectRatio.prop('checked')
        @setCropWidth(@cropAspectRatio.height * @getCropWidth())

    @applyInputEvent @inputs.cropHeight, =>
      if @inputs.cropAspectRatio.prop('checked')
        @setCropWidth(@cropAspectRatio.width * @getCropHeight())

    @refreshCropAspectRatioState()
    @inputs.cropAspectRatio.change =>
      @refreshCropAspectRatioState()

  applyResizeInputEvents: ->
    if @inputs.resized.length > 0
      @refreshResizedState()
      @inputs.resized.change =>
        @refreshResizedState()

    @applyInputEvent @inputs.resizeWidth, =>
      if @inputs.resizeAspectRatio.prop('checked')
        @setResizeHeight(@resizeAspectRatio.height * @getResizeWidth())
    @applyInputEvent @inputs.resizeHeight, =>
      if @inputs.resizeAspectRatio.prop('checked')
        @setResizeWidth(@resizeAspectRatio.width * @getResizeHeight())
    
    @refreshResizeAspectRatioState()
    @inputs.resizeAspectRatio.change =>
      @refreshResizeAspectRatioState()

    @applyResizeScaleButtonEvents()

  applyResizeScaleButtonEvents: ->
    _this = @

    @inputs.resizeScaleButtons.click ->
      $button = $(@)
      factor = $button.data('factor')
      _this.setResizeWidth(factor * _this.getCropWidth())
      _this.setResizeHeight(factor * _this.getCropHeight())

    @container.on 'init.cropper crop.cropper resize.cropper', ->
      _this.inputs.resizeScaleButtons.each ->
        $button = $(@)
        factor = $button.data('factor')
        scaledWidth = _this.getCropWidth() * factor
        scaledHeight = _this.getCropHeight() * factor
        if scaledWidth == _this.getResizeWidth() and scaledHeight == _this.getResizeHeight()
          $button.addClass('active')
        else
          $button.removeClass('active')

  applyImageEvents: ->
    @setCropAreaExplicitly = false
    @cropper = undefined
    @image.load =>
      @initCropper()
      @applyInputEvents()
      @updateCropArea()
      @container.trigger('init.cropper')

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

  getResizeCropRatio: ->
    result = {}
    cropWidth = @getCropWidth()
    if cropWidth <= 0
      result.width = 0
    else
      result.width = @getResizeWidth() / cropWidth
    cropHeight = @getCropHeight()
    if cropHeight <= 0
      result.height = 0
    else
      result.height = @getResizeHeight() / cropHeight

  setCropX: (x) ->
    x = Math.round(x)
    @inputs.cropX.val(x).attr('max', @getMaxCropWidth()).trigger('crop.cropper')
    @inputs.cropWidth.attr('max', @getMaxCropWidth())
    return x

  setCropY: (y) ->
    y = Math.round(y)
    @inputs.cropY.val(y).attr('max', @getMaxCropHeight()).trigger('crop.cropper')
    @inputs.cropHeight.attr('max', @getMaxCropHeight())
    return y

  setCropWidth: (width) ->
    width = Math.round(width)
    width = @getMaxCropWidth() if width > @getMaxCropWidth()
    @inputs.cropWidth.val(width).trigger('crop.cropper')
    return width

  setCropHeight: (height) ->
    height = Math.round(height)
    height = @getMaxCropHeight() if height > @getMaxCropHeight()
    @inputs.cropHeight.val(height).trigger('crop.cropper')
    return height

  setCropArea: (x, y, width, height) ->
    @setCropX(x)
    @setCropY(y)
    @setCropWidth(width)
    @setCropHeight(height)

  setResizeWidth: (width) ->
    @inputs.resizeWidth.val(Math.round(width)).trigger('resize.cropper')

  setResizeHeight: (height) ->
    @inputs.resizeHeight.val(Math.round(height)).trigger('resize.cropper')

  updateCropArea: ->
    @cropper.setSelect([
      @getCropX(),
      @getCropY(),
      @getCropX() + @getCropWidth(),
      @getCropY() + @getCropHeight()
    ])

  # Helper Functions

  applyInputEvent: ($input, callback) ->
    value = $input.val()
    $input.data('prevValue', value)

    $input.on 'textchange blur', =>
      value = $input.val()
      if presentString(value)
        if $input.data('prevValue') != value
          $input.trigger('crop.cropper')
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
    @cropAspectRatio = {}
    if @inputs.cropAspectRatio.prop('checked')
      @cropAspectRatio.width = @inputs.cropWidth.val() / @inputs.cropHeight.val()
      @cropAspectRatio.height = @inputs.cropHeight.val() / @inputs.cropWidth.val()
    @cropper.setOptions(aspectRatio: @cropAspectRatio.width || null)

  refreshResizeAspectRatioState: ->
    @resizeAspectRatio = {}
    if @inputs.resizeAspectRatio.prop('checked')
      @resizeAspectRatio.width = @inputs.resizeWidth.val() / @inputs.resizeHeight.val()
      @resizeAspectRatio.height = @inputs.resizeHeight.val() / @inputs.resizeWidth.val()

  refreshResizeCropRatio: ->
    @resizeCropRatio = @getResizeCropRatio() if @resizeable

$(document).ready ->

  @cropper = new Cropper($('#crop_fields'))

  # cropper = new Cropper($image, cropX: $cropX, cropY: $cropY, cropWidth: $cropWidth, cropHeight: $cropHeight, resizeWidth: $resizeWidth, resizeHeight: $resizeHeight)

