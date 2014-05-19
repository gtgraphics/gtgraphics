module PageEditorHelper
  def page_editor
    if editing?
      javascript_tag <<-JAVASCRIPT.strip_heredoc
        if (window.parent) {
          window.parent.PageEditor.open(#{@page.id}, '#{I18n.locale}');
        }
      JAVASCRIPT
    end
  end
end