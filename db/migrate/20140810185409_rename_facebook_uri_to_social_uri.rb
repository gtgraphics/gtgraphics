class RenameFacebookUriToSocialUri < ActiveRecord::Migration
  def up
    rename_metadata_key :facebook_uri, :social_uri
  end

  def down
    rename_metadata_key :social_uri, :facebook_uri
  end

  private
  def rename_metadata_key(source_key, destination_key)
    source_key = source_key.to_sym
    destination_key = destination_key.to_sym
    
    pages = select_all "SELECT id, metadata FROM pages"
    pages.each do |page|
      page_id = page['id']
      metadata = page['metadata']
      if metadata.present?
        metadata = YAML.load(metadata).symbolize_keys
      else
        metadata = {}
      end

      raise "destination key is already set" if metadata[destination_key]

      metadata[destination_key] = metadata.delete(source_key)
      metadata = quote(metadata.to_yaml)

      update "UPDATE pages SET metadata = #{metadata} WHERE id = #{page_id}"
    end
  end
end
