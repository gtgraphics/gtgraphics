class Admin::Page::RedirectionPresenter < Admin::ApplicationPresenter
  def destination
    if external?
      hostname = URI(destination_url).host
      h.link_to destination_url, target: '_blank' do
        h.append_icon :external_link, hostname, fixed_width: true
      end
    else
      h.link_to destination_page, [:admin, destination_page]
    end
  end
end