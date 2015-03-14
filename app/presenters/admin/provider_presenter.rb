class Admin::ProviderPresenter < Admin::ApplicationPresenter
  presents :provider

  self.action_buttons -= [:show]

  def thumbnail(*args)
    options = args.extract_options!
    options = options.reverse_merge(
      width: options[:size],
      height: options[:size],
      class: 'img-rounded img-editable img-editable-sm'
    )
    linked = args.first
    content = h.image_tag(
      h.attached_asset_path(provider, :thumbnail, from: :logo), options)
    h.link_to_if linked, content, [:admin, provider]
  end

  def name(linked = false)
    h.link_to_if linked, provider.name, [:edit, :admin, provider]
  end

  def to_s
    name(false)
  end
end
