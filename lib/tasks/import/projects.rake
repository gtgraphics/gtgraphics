namespace :gtg do
  namespace :import do
    desc 'Import all remote GT Graphics projects'
    task :projects => :environment do

      gallery_parser = Import::GalleryPageParser.new('showcase')
      gallery_parser.page_urls.each do |project_page_url|

        puts "- #{project_page_url}"

        project_parser = Import::ProjectPageParser.new(project_page_url)

        path = "about/#{project_parser.author.first_name.parameterize}/projects"
        gallery_page = Page.find_by! path: path

        # Project Page
        project_page = gallery_page.children.projects.new
        project_page.build_embeddable(template: "Template::Project".constantize.default)

        I18n.available_locales.each do |locale|
          Globalize.with_locale(locale) do
            project_parser.with_locale(locale) do
              project_page.title = project_parser.title
              project_page.meta_description = HTML::FullSanitizer.new.sanitize(project_parser.description)

              project_page.embeddable.name = project_parser.title
              project_page.embeddable.description = project_parser.description
            end
          end
        end

        project_page.save!

        # Images and Image Pages nested in Project Page
        project_parser.asset_urls.each_with_index do |asset_url, index|
          puts "-- #{asset_url}"

          image_page = project_page.children.images.new

          image = Image.new
          image.remote_asset_url = asset_url
          image.original_filename = File.basename(image.remote_asset_url)

          I18n.available_locales.each do |locale|
            Globalize.with_locale(locale) do
              project_parser.with_locale(locale) do
                image_page.title = "#{project_parser.title} (#{index.next})"
                image.title = "#{project_parser.title} (#{index.next})"
              end
            end
          end

          image.save!

          image_page.build_embeddable(image: image, template: "Template::Image".constantize.default)
          image_page.set_next_available_slug
          image_page.save!
        end

        # TODO Redirections in work/projects

      end
    end


  end
end