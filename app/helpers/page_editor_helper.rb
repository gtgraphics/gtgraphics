module PageEditorHelper
  def page_editor
    if editing?
      javascript_tag do
        raw %{
          if (window.parent) {
            window.parent.PageEditor.open(#{@page.id}, '#{I18n.locale}');
          }
        }.strip_heredoc
      end
    end
  end
end