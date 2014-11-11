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
  'contact' => { type: :contact_form, de: 'Kontakt', en: 'Contact', menu: false },
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
      template_class.template_files(true).each do |template_file|
        filename = File.basename(template_file).gsub(/\.(.*)\z/, '')

        template = template_class.find_or_initialize_by(file_name: filename)
        I18n.with_locale :de do
          if filename == 'default'
            template.name = template_class.model_name.human
          else
            template.name = filename.titleize
          end
        end

        # Scan the document for defined regions
        template_doc = IO.read(template_file)
        region_names = template_doc.scan(/render_region :([a-z_]+)/).flatten

        template.region_definitions.reject { |definition|
          definition.label.in?(region_names) }.each(&:mark_for_destruction)

        region_names.each do |region_name|
          template.region_definitions.find_or_initialize_by(label: region_name) do |definition|
            definition.name = region_name.titleize
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
      embeddable_type = "Page::#{page_type}"
      type_changed = page.persisted? and embeddable_type != page.embeddable_type
      if page.embeddable.nil? or type_changed
        page.embeddable.destroy if type_changed
        page.embeddable_type = embeddable_type
        embeddable = page.build_embeddable        
      end
      page.template = template if page.support_templates?

      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          page.title = config[locale]
        end
      end

      page.published = config.fetch(:published, true)
      page.menu_item = config.fetch(:menu, true)

      if page.contact_form?
        embeddable.recipients = User.all
      end

      page.save!
    end
  end
end