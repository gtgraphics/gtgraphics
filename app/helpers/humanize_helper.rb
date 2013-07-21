module HumanizeHelper
  def yes_or_no(value)
    translate(value ? :yes : :no, scope: 'helpers.boolean')
  end
end