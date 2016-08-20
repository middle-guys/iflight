class NotificationJob < ApplicationJob
  queue_as :default

  def perform
    #alerts = Alert.where(status:"active").select(:ori_air_id, :des_air_id, :time_start).distinct
    alerts = Alert.where(status: :active)
    alerts.each do |alert|
      search_tickets(alert)
    end
  end

  private
  def search_tickets(alert)
    flight_search = SearchFlight::Base.new(ori_code: Airport.find(alert.ori_air_id).code, des_code: Airport.find(alert.des_air_id).code, depart_date: alert.time_start, adult: 1, child: 0, infant: 0, round_type: "OW")
    flights = flight_search.call
    if flights[:depart_flights].count > 0
      flights_order = flights[:depart_flights].sort_by{|ob| ob[:price_adult]}
      ticket_cheapest = flights_order.first
      if alert.price_expect.to_i >= ticket_cheapest[:price_adult]
        UserMailer.notification_email(alert).deliver_now
      end
    end
  end
end
