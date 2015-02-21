namespace :gtg do
  namespace :import do
    desc 'Import all remote GTGRAPHICS projects'
    task projects: :environment do
      puts 'Destroying existing Projects'
      Project.destroy_all

      puts 'Importing Projects'

      showcase_pages = {}

      gallery_parser = Import::GalleryPageParser.new('showcase')
      gallery_parser.page_urls.each do |project_page_url|

        puts "- #{project_page_url}"

        project_parser = Import::ProjectPageParser.new(project_page_url)

        path = 'showcase'

        showcase_page = showcase_pages[path] ||= begin
          page = Page.find_by(path: path)
          raise "no showcase page found on #{path}" if page.nil?
          page
        end

        # Project
        Project.transaction do
          project = Project.new
          project.project_type = project_parser.project_type
          project.author = project_parser.author

          I18n.available_locales.each do |locale|
            Globalize.with_locale(locale) do
              project_parser.with_locale(locale) do
                project.title = project_parser.project_title
                project.description = project_parser.description
                project.url = project_parser.url
              end
            end
          end

          # Import and assign Images that are embedded in Project page
          images = import_images(project_parser)
          images.each do |image|
            project.project_images.build(image: image)
          end

          project.save!

          # Create Project Page in Author Showcase
          page = showcase_page.children.projects.new
          page.build_embeddable.tap do |project_page|
            project_page.project = project
            project_page.template = "Template::Project".constantize.default!
          end

          I18n.available_locales.each do |locale|
            Globalize.with_locale(locale) do
              page.title = project.title
              page.meta_description = HTML::FullSanitizer.new.sanitize(project.description)
            end
          end


          page.set_next_available_slug
          page.save!
        end
      end
    end

    def import_images(project_parser)
      append_index_to_title = project_parser.asset_urls.many?

      project_parser.asset_urls.collect.with_index do |asset_url, index|
        puts "-- #{asset_url}"

        image = Image.new
        image.remote_asset_url = asset_url
        image.original_filename = File.basename(image.remote_asset_url)
        image.author = project_parser.author
        image.tag 'Projekt', 'Project', project_parser.project_type

        I18n.available_locales.each do |locale|
          I18n.with_locale(locale) do
            project_parser.with_locale(locale) do
              if append_index_to_title
                image.title = "#{project_parser.project_title} (#{index.next})"
              else
                image.title = project_parser.project_title
              end
            end
          end
        end

        image.tap(&:save!)
      end
    end
  end
end
