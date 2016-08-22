class NotificationJob < ApplicationJob
  queue_as :default

  def perform
    #alerts = Alert.where(status:"active").select(:ori_air_id, :des_air_id, :time_start).distinct
    searchs = Alert.where("status= ? AND time_start >= ?", :active, Date.today).select(:ori_air_id, :des_air_id, :time_start).distinct
    searchs.each do |searchs|
      alerts = get_alerts(searchs)
      search_tickets(searchs, alerts)
    end
  end

  private
  def search_tickets(searchs, alerts)
    flight_search = SearchFlight::Base.new(ori_code: Airport.find(searchs.ori_air_id).code, des_code: Airport.find(searchs.des_air_id).code, date_depart: searchs.time_start.to_s, adult: 1, child: 0, infant: 0, round_type: "OW")
    flights = flight_search.call
    if flights[:depart_flights].count > 0
      #flights_order = flights[:depart_flights].sort_by{|ob| ob[:price_adult]}
      alerts.each do |alert|
        ticket_cheaps = Array.new
        flights[:depart_flights].each do |flight|
          if alert.price_expect.to_i >= flight[:price_adult]
            ticket_cheaps.push(flight)
          end
        end
        if ticket_cheaps.count > 0
          FlightMailer.alert_notification(alert, ticket_cheaps).deliver_now
        end
      end
    end
  end

  def get_alerts(searchs)
    Alert.where('ori_air_id= ? AND des_air_id= ? AND time_start= ?', searchs.ori_air_id, searchs.des_air_id, searchs.time_start)
  end
end
