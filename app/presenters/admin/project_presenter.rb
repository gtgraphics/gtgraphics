class Admin::ProjectPresenter < Admin::ApplicationPresenter
  presents :project
  
  def author
    present project.author, with: Admin::UserPresenter 
  end

  def client(linked = false)
    if client_name.present?
      h.link_to_if linked, client_name, [:admin, project.client]
    else
      placeholder
    end
  end

  def image
    @image = project.images.first unless defined? @image
    @image
  end

  def pages_count
    count = project.pages.count
    h.link_to "#{count} #{Page.model_name.human(count: count)}", [:pages, :admin, project], remote: true
  end

  def released_in
    super.presence || placeholder
  end

  def summary
    human_name = Image.model_name.human(count: project.images_count)
    "#{project.images_count} #{human_name}"
  end

  def thumbnail(options = {})
    if image
      width = height = options.delete(:size) { 300 }
      options = options.reverse_merge(class: 'img-circle', alt: image.title, width: width, height: height)
      h.image_tag image.asset.url(:thumbnail), options
    end
  end
end