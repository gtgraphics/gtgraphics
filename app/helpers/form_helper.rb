module FormHelper
  def form_actions(horizontal = true, &block)
    content_tag :div, class: 'form-actions form-group' do
      if horizontal
        content_tag :div, class: 'col-sm-offset-3 col-sm-9', &block
      else
        concat capture(&block)
      end
    end
  end
end