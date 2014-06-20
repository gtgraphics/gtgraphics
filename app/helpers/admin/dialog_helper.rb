module Admin::DialogHelper
  def dialog(&block)
    content_tag :div, class: 'row' do
      content_tag :div, class: 'col-sm-offset-2 col-sm-8', &block
    end
  end
end