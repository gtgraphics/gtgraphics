set :output, '/home/gtgraphics/cron.log'

# Learn more: http://github.com/javan/whenever

# set :bundle_command, 'bin/bundle'

job_type :job_daemon, 'cd :path && :environment_variable=:environment ' \
                      ':bundle_command bin/delayed_job :output'

every :reboot do
  command 'sleep 60' # wait until the DB has loaded
  job_daemon :start
end

every :day, at: '00:00' do
  job_daemon :restart
end

every 2.weeks do
  rake 'log:rotate'
end
