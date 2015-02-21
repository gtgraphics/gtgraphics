require 'csv'

namespace :gtg do
  namespace :import do
    desc 'Import all remote GTGRAPHICS shouts from the star map'
    task :shouts => :environment do
      # TODO
      filename = ENV.fetch('FILE') { "#{Rails.root}/tmp/shoutbox.csv" }

      Shout.transaction do
        CSV.foreach(filename, headers: %i(entry_id nickname ip message timestamp x y star_type)) do |row|
          Shout.create! do |shout|
            shout.nickname = row[:nickname]
            shout.ip = row[:ip]
            shout.message = Nokogiri::HTML(row[:message]).text
            shout.created_at = DateTime.strptime(row[:timestamp], '%s')
            shout.x = row[:x]
            shout.y = row[:y]
            shout.star_type = row[:star_type]
          end
        end
      end
    end
  end
end
