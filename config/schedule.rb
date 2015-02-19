# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :bundle_command, 'bin/bundle'

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
