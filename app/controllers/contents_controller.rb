class ContentsController < PagesController
  before_action :load_content

  def show
    @content_pages = @page.children_with_embedded(:content)
    super
  end

  private
  def load_content
    @content = @page.embeddable
  end
end