namespace :cache do
  desc 'Rebuild CMS routes for the environment'
  task rebuild_routes: :environment do
    Routing::Cms::RouteCache.rebuild
  end
end
