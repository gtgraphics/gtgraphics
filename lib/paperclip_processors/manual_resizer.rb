module Paperclip
  class ManualResizer < Thumbnail
    def initialize(file, options = {}, attachment = nil)
      super
      if target.resized?
        @current_geometry.width = target.resize_width
        @current_geometry.height = target.resize_height
      end
    end

    def target
      @attachment.instance
    end

    def transformation_command
      resize_command + super
    end

    private
    def resize_command
      resize_command = []
      resize_command += ['-resize', target.resize_geometry] if target.resized?
      resize_command
    end
  end
end