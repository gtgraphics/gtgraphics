# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.benchmark "Seeding Users" do
  User.create! first_name: 'Tobias', last_name: 'Casper', email: 'tobias.casper@gmail.com', password: 'Test1234', password_confirmation: 'Test1234'
  User.create! first_name: 'Tobias', last_name: 'Roetsch', email: 't.roetsch@gtgraphics.de', password: 'Test1234', password_confirmation: 'Test1234'
  User.create! first_name: 'Jeff', last_name: 'Michelmann', email: 'j.michelmann@gtgraphics.de', password: 'Test1234', password_confirmation: 'Test1234'
end

Template.benchmark "Seeding Templates" do
  Template.template_types.each do |template_type|
    template_class = template_type.constantize
    template_class.template_files.each do |template_file|
      template = template_class.new(file_name: template_file)
      template.translations.build(locale: :en, name: template_file.humanize)
      template.save!
    end
  end
end