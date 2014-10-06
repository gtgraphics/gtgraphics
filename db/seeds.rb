USERS = {
  'webmaster' => ['Tobias', 'Casper'],
  't.roetsch' => ['Tobias', 'Roetsch'],
  'j.michelmann' => ['Jeff', 'Michelmann']
}.freeze

PAGES = {
  '' => { type: :homepage, de: 'Startseite', en: 'Homepage' },
  'wallpapers' => { template: :gallery, de: 'Wallpaper', en: 'Wallpapers' },
  'artworks' => { template: :gallery, de: 'Artworks', en: 'Artworks' },
  'photography' => { template: :gallery, de: 'Photos', en: 'Photos' },
  'showcase' => { template: :showcase, de: 'Showcase', en: 'Showcase' },
  'prints' => { de: 'Prints', en: 'Prints' },
  'about' => { de: 'Über uns', en: 'About Us' },
  'about/tobias' => { de: 'Tobias Roetsch', en: 'Tobias Roetsch' },
  'about/jeff' => { de: 'Jeff Michelmann', en: 'Jeff Michelmann' },
  'contact' => { de: 'Kontakt', en: 'Contact', menu: false },
  'imprint' => { de: 'Impressum', en: 'Imprint', menu: false }
}.freeze


puts "Seeding Users"
User.benchmark "Seeding Users" do
  User.transaction do
    USERS.each do |username, name|
      user = User.find_or_initialize_by(first_name: name.first, last_name: name.last)
      user.email = "#{username}@gtgraphics.de"
      user.password = 'Test1234' if user.new_record?
      user.save!
    end
  end
end

puts "Seeding Templates"
Template.benchmark "Seeding Templates" do
  Template.transaction do
    Template.template_types.each do |template_type|
      template_class = template_type.constantize
      template_class.template_files.each do |template_file|
        template = template_class.find_or_initialize_by(file_name: template_file)
        I18n.with_locale :de do
          if template_file == 'default'
            template.name = template_class.model_name.human
          else
            template.name = template_file.titleize
          end
        end
        template.save!
      end
    end
  end
end

Page.transaction do
  PAGES.each do |path, config|
    bm_title = path.blank? ? "Seeding Homepage" : "Seeding Page: #{path}"

    puts bm_title
    Page.benchmark(bm_title) do
      if path.present?
        path_segments = path.split('/')
        slug = path_segments.pop
        parent_path = path_segments.join('/')
        parent = Page.find_by!(path: parent_path)
      else
        path = ''
      end

      page_type = config.fetch(:type, :content).to_s.classify

      template_class = "Template::#{page_type}".constantize
      template = template_class.find_by!(file_name: config.fetch(:template, :default))

      page = Page.find_by(path: path)
      page ||= parent ? parent.children.new : Page.roots.new
      page.slug = slug if page.new_record?
      if page.embeddable.nil?
        page.embeddable_type = "Page::#{page_type}"
        page.build_embeddable
      end
      page.template = template if page.support_templates?

      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          page.title = config[locale]
        end
      end

      page.published = config.fetch(:published, true)
      page.menu_item = config.fetch(:menu, true)

      page.save!
    end
  end
end