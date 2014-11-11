namespace :db do
  task drop_tables: :environment do
    connection = ActiveRecord::Base.connection
    connection.tables.sort.each do |table_name|
      connection.execute("DROP TABLE #{table_name} CASCADE")
      puts "Dropped: #{table_name}"
    end
  end

  task truncate: :environment do
    connection = ActiveRecord::Base.connection
    tables = connection.tables.sort - %w(schema_migrations)
    tables.each do |table_name|
      connection.execute("TRUNCATE TABLE #{table_name}")
      puts "Truncated: #{table_name}"
    end
  end
end