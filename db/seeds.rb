# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.benchmark "Seeding Users" do
  User.create! first_name: 'Tobias', last_name: 'Casper', email: 'webmaster@gtgraphics.de', password: 'Test1234', password_confirmation: 'Test1234'
  User.create! first_name: 'Tobias', last_name: 'Roetsch', email: 't.roetsch@gtgraphics.de', password: 'Test1234', password_confirmation: 'Test1234'
  User.create! first_name: 'Jeff', last_name: 'Michelmann', email: 'j.michelmann@gtgraphics.de', password: 'Test1234', password_confirmation: 'Test1234'
end

Template.benchmark "Seeding Templates" do
  Template.template_types.each do |template_type|
    template_class = template_type.constantize
    template_class.template_files.each do |template_file|
      template = template_class.new(file_name: template_file)
      template.translations.build(locale: :en, name: template_file.titleize)
      template.save!
    end
  end
end

Page.benchmark "Seeding Homepage" do
  homepage = Page::Homepage.new
  homepage.template = Template::Homepage.first

  page = Page.new
  page.embeddable = homepage
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) do
      page.translations.build(locale: locale, title: Page::Homepage.model_name.human)
    end
  end
  page.author = User.find_by!(email: 'webmaster@gtgraphics.de')
  page.save!
end