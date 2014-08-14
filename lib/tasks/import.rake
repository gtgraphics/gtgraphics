namespace :gtg do
  namespace :import do
    desc 'Import everything from remote GT Graphics'
    task :all => ['gtg:import:projects',
                  'gtg:import:galleries:all']
  end
end