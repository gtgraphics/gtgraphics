class AddTransformedDimensionsToImageStyles < ActiveRecord::Migration
  def change
    add_column :image_styles, :transformed_width, :integer
    add_column :image_styles, :transformed_height, :integer

    Image::Style.reset_column_information

    reversible do |dir|
      dir.up do
        Image::Style.all.each(&:save!)
      end
    end
  end
end
