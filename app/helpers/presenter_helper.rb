module PresenterHelper
  def present(presenter_name, attributes = {})
    class_name = presenter_name.to_s.classify.gsub(/Presenter\z/, '')
    class_name += 'Presenter'
    class_name.constantize.new(self, attributes).render
  end
end