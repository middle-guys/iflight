Messenger::Bot.config do |config|
  config.access_token = ENV['FB_PAGE_ACCESS_TOKEN']
  config.validation_token = ENV['FB_VERIFY_TOKEN']
  config.secret_token = ENV['FB_SECRET']
end
