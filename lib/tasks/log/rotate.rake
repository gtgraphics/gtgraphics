namespace :log do
  desc 'Compresses the current application log for the environment'
  task :rotate do
    store_path = "#{Rails.root}/log"
    logfiles = Dir[File.join(store_path, '*.log')]
    logfiles.delete_if { |l| File.size(l).zero? }
    if logfiles.any?
      log_filenames = logfiles.map { |l| File.basename(l) }.join(' ')
      archive_filename = "logs_#{Time.now.strftime('%s')}.tgz"
      `cd #{store_path} && tar -zcvf #{archive_filename} #{log_filenames}`
      logfiles.each do |logfile|
        File.open(logfile, 'w') { |file| file.truncate(0) }
      end
    end
  end
end
