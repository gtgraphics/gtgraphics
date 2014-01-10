Rails.application.config.to_prepare do
  PhantomJS.configure do |config|
    config.executable_path = "#{Rails.root}/bin/phantomjs"
  end
end