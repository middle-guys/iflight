require "flight_formulas"

class CrawlFlightsJob < ApplicationJob
  include FlightFormulas

  queue_as :default

  def perform(params)
    flight_vja = SearchFlight::VietjetAir::Search.new(params).call
    flights_jet = SearchFlight::Jetstar::Search.new(params).call
    flights_vna = SearchFlight::VietnamAirlines::Search.new(params).call

    data = {
      depart_flights: flights_jet[:depart_flights] + flights_vna[:depart_flights] + flight_vja[:depart_flights],
      return_flights: self.round_trip?(params[:round_type]) ? flights_jet[:return_flights] + flights_vna[:return_flights] + flight_vja[:return_flights] : nil
    }

    ActionCable.server.broadcast("flights-#{params[:uuid]}", flights: data)
  end
end
