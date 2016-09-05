namespace :notification do
  task alert: :environment do
    NotificationJob.perform_now
  end
end
