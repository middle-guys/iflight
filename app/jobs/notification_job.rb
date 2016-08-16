class NotificationJob < ApplicationJob
  queue_as :default

  def perform
    Alert.all.each do |alert|
      search_tickets(alert)
    end
  end

  private
  def search_tickets(alert)
  	# call craw data ticket airline (ori_airport_id, des_airport_id, time_start) in here
  	#check condition price in here
  	#if condition is oke then send email to user
  	@alert = alert
  	UserMailer.notification_email(@alert).deliver_now
  end
end
