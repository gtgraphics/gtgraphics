set :output, '/home/gtgraphics/cron.log'

every 2.weeks do
  rake 'log:rotate'
end
