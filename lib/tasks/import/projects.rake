namespace :gtg do
  namespace :import do
    desc 'Import all remote GT Graphics projects'
    task :projects => :environment do

      gallery_parser = Import::GalleryPageParser.new('showcase')
      gallery_parser.page_urls.each do |project_page_url|

        puts "- #{project_page_url}"

        project_parser = Import::ProjectPageParser.new(project_page_url)

        path = "about/#{project_parser.author.first_name.parameterize}/showcase"
        showcase_page = Page.find_by(path: path)
        raise "no showcase page found on #{path}" if showcase_page.nil?

        # Project
        project = Project.new

        I18n.available_locales.each do |locale|
          Globalize.with_locale(locale) do
            project_parser.with_locale(locale) do
              project.title = project_parser.title
              project.description = project_parser.description
              project.url = project_parser.url
            end
          end
        end

        binding.pry

        raise 'bla'

        # project.client_name = 

        # Images and Image Pages nested in Project Page
        images = import_images(project_parser)



        # Project Page
        project_page = showcase_page.children.projects.new
        project_page.build_embeddable(template: "Template::Project".constantize.default)


      end
    end

    def import_images(project_parser)
      project_parser.asset_urls.collect.with_index do |asset_url, index|
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

        image.tap(&:save!)
      end
    end
  end
end