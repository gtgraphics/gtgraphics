class ContentsController < PagesController
  before_action :load_content
  
  private
  def load_content
    @content = @page.embeddable
  end
end