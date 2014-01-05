class Template < ActiveRecord::Base
  class ContactForm < Template
    self.template_lookup_paths << 'contact_forms/templates'
  end
end