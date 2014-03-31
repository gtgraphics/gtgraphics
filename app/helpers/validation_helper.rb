module ValidationHelper
  def validators_for(form)
    form_id = form.options[:html][:id]
    record = form.object
    validators = record.class.validators

    commands = []
    validators.each do |validator|
      commands << validator.inspect # TODO
    end

    javascript_tag %{
      $(document).ready(function() {
        $form = $('##{form_id}');
        #{commands.join("\n")}
      });
    }.strip_heredoc
  end
end