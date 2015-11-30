class Image < ActiveRecord::Base
  class StylesController < DownloadsController
    before_action :load_image_style

    def download
      send_attachment @image_style, :attachment
    end

    private

    def load_image_style
      @image_style = Image::Style.find_by!(asset: params[:filename])
    end
  end
end
