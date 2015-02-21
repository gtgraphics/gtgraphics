namespace :gtg do
  namespace :import do
    desc 'Import everything from remote GTGRAPHICS'
    task :all => ['gtg:import:projects',
                  'gtg:import:galleries:all']
  end
end
