class ImageManipulator
  constructor: ($container) ->
    @$container = $container

    @$image = $('img[data-behavior="croppable"]', $container)
    @originalWidth = @$image.data('originalWidth')
    @originalHeight = @$image.data('originalHeight')

    @inputs = {}
    @panels = {
      crop: $('.crop-panel', $container)
      resize: $('.resize-panel', $container)
    }

    @croppable = @panels.crop.any()
    if @croppable
      @inputs = _(@inputs).extend
        cropped: $('[data-toggle="crop"]', $container)
        cropX: $('[data-control="cropX"]', $container)
        cropY: $('[data-control="cropY"]', $container)
        cropWidth: $('[data-control="cropWidth"]', $container)
        cropHeight: $('[data-control="cropHeight"]', $container)
        cropAspectRatio: $('[data-control="preserveCropAspectRatio"]', $container)

    @resizeable = @panels.resize.any()
    if @resizeable
      @inputs = _(@inputs).extend
        resized: $('[data-toggle="resize"]', $container)
        resizeWidth: $('[data-control="resizeWidth"]', $container)
        resizeHeight: $('[data-control="resizeHeight"]', $container)
        resizeAspectRatio: $('[data-control="preserveResizeAspectRatio"]', $container)
        scale: $('[data-control="scale"]', $container)

    @applyImageEvents()

  initCropper: ->
    return console.warn 'cropper has already been attached' if @cropper
    @cropper = $.Jcrop(@$image, {
      #bgColor: 'transparent'
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

    @$container.trigger('init.cropper')

  refreshCroppedState: (initial) ->
    enabled = @inputs.cropped.prop('checked')
    $panelCollapse = @panels.crop.find('.panel-collapse')
    if enabled
      $panelCollapse.collapse('show') unless initial
      @cropper.enable()
    else
      $panelCollapse.collapse('hide') unless initial
      @cropper.disable()
    # $panelCollapse.find(':input').prop('disabled', !enabled)
    @panels.crop.find('.panel-body').find(':input').prop('disabled', !enabled)
    @refreshSubmitButtonState()

  refreshResizedState: (initial) ->
    enabled = @inputs.resized.prop('checked')
    $panelCollapse = @panels.resize.find('.panel-collapse')
    unless initial
      if enabled
        $panelCollapse.collapse('show')
      else
        $panelCollapse.collapse('hide')
    # $panelCollapse.find(':input').prop('disabled', !enabled)
    @panels.resize.find('.panel-body').find(':input').prop('disabled', !enabled)
    @refreshSubmitButtonState()

  refreshSubmitButtonState: ->
    enabled = @inputs.cropped.prop('checked') or @inputs.resized.prop('checked')
    $(':submit', @$container).prop('disabled', !enabled)

  applyInputEvents: ->
    @applyCropEvents() if @croppable
    @applyResizeEvents() if @resizeable

  applyCropEvents: ->
    if @inputs.cropped.any()
      @refreshCroppedState(true)
      @inputs.cropped.on 'change', =>
        @refreshCroppedState(false)

    @applyInputEvent @inputs.cropX, =>
      totalWidth = @getCropX() + @getCropWidth()
      if totalWidth > @originalWidth
        @inputs.cropWidth.val(@originalWidth - @getCropX())
      @inputs.cropWidth.attr('max', @originalWidth - @getCropX())

    @applyInputEvent @inputs.cropY, =>
      totalHeight = @getCropY() + @getCropHeight()
      if totalHeight > @originalHeight
        @inputs.cropHeight.val(@originalHeight - @getCropY())
      @inputs.cropHeight.attr('max', @originalHeight - @getCropY())

    @applyInputEvent @inputs.cropWidth, =>
      @inputs.cropWidth.attr('max', @originalWidth - @getCropX())
      if @inputs.cropAspectRatio.prop('checked')
        @setCropHeight(@cropAspectRatio.height * @getCropWidth())

    @applyInputEvent @inputs.cropHeight, =>
      @inputs.cropHeight.attr('max', @originalHeight - @getCropY())
      if @inputs.cropAspectRatio.prop('checked')
        @setCropWidth(@cropAspectRatio.width * @getCropHeight())

    @refreshCropAspectRatioState()
    @inputs.cropAspectRatio.on 'change', =>
      @refreshCropAspectRatioState()

  applyResizeEvents: ->
    if @inputs.resized.any()
      @refreshResizedState(true)
      @inputs.resized.on 'change', =>
        @refreshResizedState(false)

    @applyInputEvent @inputs.resizeWidth, =>
      if @inputs.resizeAspectRatio.prop('checked')
        @setResizeHeight(@resizeAspectRatio.height * @getResizeWidth())

    @applyInputEvent @inputs.resizeHeight, =>
      if @inputs.resizeAspectRatio.prop('checked')
        @setResizeWidth(@resizeAspectRatio.width * @getResizeHeight())

    @refreshResizeAspectRatioState()
    @inputs.resizeAspectRatio.on 'change', =>
      @refreshResizeAspectRatioState()

    @applyScaleEvents()

  applyScaleEvents: ->
    _this = @

    @inputs.scale.click ->
      $button = $(@)
      factor = $button.val()
      _this.setResizeWidth(factor * _this.getCropWidth())
      _this.setResizeHeight(factor * _this.getCropHeight())
      _this.refreshCropAspectRatioState() if _this.croppable
      _this.refreshResizeAspectRatioState() if _this.resizeable

    @$container.on 'init.cropper crop.cropper resize.cropper', ->
      _this.inputs.scale.each ->
        $button = $(@)
        factor = $button.val()
        scaledWidth = _this.getCropWidth() * factor
        scaledHeight = _this.getCropHeight() * factor
        if scaledWidth == _this.getResizeWidth() and scaledHeight == _this.getResizeHeight()
          $button.addClass('active')
        else
          $button.removeClass('active')

  applyImageEvents: ->
    @setCropAreaExplicitly = false
    @cropper = undefined
    @prepareImage()
    @$image.load =>
      @prepareImage()

  prepareImage: ->
    @initCropper()
    @applyInputEvents()
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
    ], false)

  # Helper Functions

  applyInputEvent: ($input, callback) ->
    value = $input.val()
    $input.data('prevValue', value)

    $input.on 'textchange', (event) =>
      value = $input.val()
      unless emptyString(value)
        if $input.data('prevValue') != value
          $input.trigger('crop.cropper')
          @setCropAreaExplicitly = true
          callback(event) if callback
          @updateCropArea()
        $input.data('prevValue', value)

  emptyString = (value) ->
    jQuery.trim(value) == ''

  parseValue = (value) ->
    value = Number(value)
    value = 0 if isNaN(value)
    value

  refreshCropAspectRatioState: ->
    @cropAspectRatio = {}
    if @croppable and @inputs.cropAspectRatio.prop('checked')
      @cropAspectRatio.width = @inputs.cropWidth.val() / @inputs.cropHeight.val()
      @cropAspectRatio.height = @inputs.cropHeight.val() / @inputs.cropWidth.val()
      @cropAspectRatio.originalWidth = @inputs.cropWidth.val()
      @cropAspectRatio.originalHeight = @inputs.cropHeight.val()
      @cropper.setOptions(aspectRatio: @cropAspectRatio.width)
    else
      @cropAspectRatio.width = null
      @cropAspectRatio.height = null
      @cropAspectRatio.originalWidth = null
      @cropAspectRatio.originalHeight = null
      @cropper.setOptions(aspectRatio: null)
    @setCropWidth(@cropAspectRatio.originalWidth) if @cropAspectRatio.originalWidth
    @setCropHeight(@cropAspectRatio.originalHeight) if @cropAspectRatio.originalHeight

  refreshResizeAspectRatioState: ->
    @resizeAspectRatio = {}
    if @resizeable and @inputs.resizeAspectRatio.prop('checked')
      @resizeAspectRatio.width = @inputs.resizeWidth.val() / @inputs.resizeHeight.val()
      @resizeAspectRatio.height = @inputs.resizeHeight.val() / @inputs.resizeWidth.val()
      @resizeAspectRatio.originalWidth = @inputs.resizeWidth.val()
      @resizeAspectRatio.originalHeight = @inputs.resizeHeight.val()
    else
      @resizeAspectRatio.width = null
      @resizeAspectRatio.height = null
      @resizeAspectRatio.originalWidth = null
      @resizeAspectRatio.originalHeight = null

  refreshResizeCropRatio: ->
    @resizeCropRatio = @getResizeCropRatio() if @resizeable

# $(document).ready ->
#   $imageManipulator = $('#image_manipulator')
#   new ImageManipulator($imageManipulator)


$(document).on 'shown.bs.modal', ->
  $imageManipulator = $('#image_manipulator')
  if $imageManipulator.any()
    new ImageManipulator($imageManipulator)
