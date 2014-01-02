class AddCustomizationOptionsToImages < ActiveRecord::Migration
  def up
    add_column :images, :customization_options, :text

    images = execute("SELECT * FROM images").to_a
    images.each do |image|
      id = image['id']
      values = {}
      %w(crop_x crop_y crop_width crop_height).each do |key|
        values[key] = image[key].to_i
      end
      customization_options = YAML.dump(values.with_indifferent_access)
      update("UPDATE images SET customization_options = #{quote(customization_options)} WHERE id = #{id}")
    end

    remove_column :images, :crop_x
    remove_column :images, :crop_y
    remove_column :images, :crop_width
    remove_column :images, :crop_height
  end

  def down
    add_column :images, :crop_x, :integer
    add_column :images, :crop_y, :integer
    add_column :images, :crop_width, :integer
    add_column :images, :crop_height, :integer

    images = execute("SELECT * FROM images").to_a
    images.each do |image|
      id = image['id']
      customization_options = YAML.load(image['customization_options'])
      values = customization_options.map { |key, value| "#{key} = #{quote(value)}" }.join(', ')
      update("UPDATE images SET #{values} WHERE id = #{id}")
    end

    remove_column :images, :customization_options
  end
end
