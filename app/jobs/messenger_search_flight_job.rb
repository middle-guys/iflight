require "flight_formulas"

class MessengerSearchFlightJob < ApplicationJob
  include FlightFormulas
  queue_as :default

  def perform(params)
    begin
      flight_vja = SearchFlight::VietjetAir::Search.new(params).call
      flights_jet = SearchFlight::Jetstar::Search.new(params).call
      flights_vna = SearchFlight::VietnamAirlines::Search.new(params).call

      data = {
        depart_flights: flights_jet[:depart_flights] + flights_vna[:depart_flights] + flight_vja[:depart_flights],
        return_flights: round_trip?(params[:round_type]) ? flights_jet[:return_flights] + flights_vna[:return_flights] + flight_vja[:return_flights] : nil,
        itinerary: {
          category: params[:round_type],
          ori_airport: Airport.find_by(code: params[:ori_code]),
          des_airport: Airport.find_by(code: params[:des_code]),
          date_depart: params[:date_depart],
          date_return: params[:date_return],
          adult_num: params[:adult],
          child_num: params[:child],
          infant_num: params[:infant]
        }
      }
    rescue Exception => e
      p e.message

      data = {
        error: 404
      }
    end

    bot = MessengerBot.new
    is_round_trip = round_trip?(params[:round_type])

    if data[:error].present? || (data[:depart_flights].size == 0 && !is_round_trip) || (data[:depart_flights].size == 0 && data[:return_flights].size == 0 && is_round_trip)
      bot.send_message(params[:recipient_id], "Sorry, we can't search flight at the moment.")
    else
      depart_flights = data[:depart_flights].sort_by { |flight| flight[:price_adult] }.take(3)
      bot.send_message(params[:recipient_id], "Here is the depart result:")

      depart_flights.each do |flight|
        bot.send_message(params[:recipient_id], format_message(flight))
      end

      if is_round_trip
        return_flights = data[:return_flights].sort_by { |flight| flight[:price_adult] }.take(3)
        bot.send_message(params[:recipient_id], "Here is the return result:")

        return_flights.each do |flight|
          bot.send_message(params[:recipient_id], format_message(flight))
        end
      end
    end
  end

  def format_message(flight)
    "#{flight[:airline_type].titleize} (#{flight[:code_flight]}). Time: #{flight[:time_depart]} - #{flight[:time_arrive]}. Price: #{flight[:price_adult]}"
  end
end