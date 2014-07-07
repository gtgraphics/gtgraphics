class Admin::ImageUploadActivity < Activity
  attr_accessor :asset
  attr_reader :image
  
  def perform
    @image = Image.new
    @image.asset = asset
    @image.save!
  end
end