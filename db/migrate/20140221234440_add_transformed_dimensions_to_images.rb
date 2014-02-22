class AddTransformedDimensionsToImages < ActiveRecord::Migration
  def change
    add_column :images, :transformed_width, :integer
    add_column :images, :transformed_height, :integer

    Image.reset_column_information

    reversible do |dir|
      dir.up do
        Image.all.each do |image|
          if image.customization_options.any?
            image.cropped = true
          else
            image.cropped = false
          end
          if image.cropped?
            image.transformed_width = image.crop_width
            image.transformed_height = image.crop_height
          else
            image.transformed_width = image.width
            image.transformed_height = image.height
          end
          image.save!
        end
      end
    end
  end
end
