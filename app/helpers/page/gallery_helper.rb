module Page::GalleryHelper
  def gallery_cache_key(image_pages)
    [page, :gallery,
     image_pages.current_page, image_pages.total_count,
     image_pages.maximum(:updated_at)]
  end
end
