namespace :notification do
  task alert: :environment do
    NotificationJob.perform_later
  end
end
