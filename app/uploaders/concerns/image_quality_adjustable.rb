module ImageQualityAdjustable
  extend ActiveSupport::Concern

  protected

  def quality(percentage)
    manipulate! do |img|
      unless img.quality == percentage
        img.write(current_path) do
          self.quality = percentage
        end
      end
      img = yield(img) if block_given?
      img
    end
  end
end
