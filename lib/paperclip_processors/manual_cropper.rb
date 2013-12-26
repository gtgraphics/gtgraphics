module Paperclip
  class ManualCropper < Thumbnail
    def initialize(file, options = {}, attachment = nil)
      super
      if target.cropped?
        @current_geometry.width = target.crop_width
        @current_geometry.height = target.crop_height
      end
    end

    def target
      @attachment.instance
    end

    def transformation_command
      crop_command + super
    end

    private
    def crop_command
      crop_command = []
      crop_command += [
        "-crop",
        "#{target.crop_width}x" \
          "#{target.crop_height}+" \
          "#{target.crop_x}+" \
          "#{target.crop_y}",
        "+repage"
      ] if target.cropped?
      crop_command
    end
  end
end