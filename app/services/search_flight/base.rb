module SearchFlight
  class Base
    attr_accessor :params

    def initialize(params)
      @params = params
    end

    def call
      flight_vja = SearchFlight::VietjetAir::Search.new(params).call
      flights_jet = SearchFlight::Jetstar::Search.new(params).call
      flights_vna = SearchFlight::VietnamAirlines::Search.new(params).call

      {
        depart_flights: flights_jet[:depart_flights] + flights_vna[:depart_flights] + flight_vja[:depart_flights],
        return_flights: params[:round_type] == "RoundTrip" ? flights_jet[:return_flights] + flights_vna[:return_flights] + flight_vja[:return_flights] : nil
      }
    end
  end
end
