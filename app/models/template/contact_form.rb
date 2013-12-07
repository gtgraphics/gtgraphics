class Template < ActiveRecord::Base
  class ContactForm < Template
    self.template_lookup_path = 'contact_forms/templates'
  end
end
