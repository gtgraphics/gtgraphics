module FormHelper
  def form_actions(horizontal = true, &block)
    content_tag :div, class: 'form-actions' do
      if horizontal
        content_tag :div, class: 'row' do
          content_tag :div, class: 'col-sm-offset-3', &block
        end
      else
        concat capture(&block)
      end
    end
  end
end