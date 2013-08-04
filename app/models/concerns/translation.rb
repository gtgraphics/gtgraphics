module Translation
  extend ActiveSupport::Concern

  included do
    translatable_model = self.name.deconstantize.constantize

    belongs_to translatable_model.model_name.singular.to_sym, class_name: translatable_model.name
  end
end