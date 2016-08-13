require "flight_formulas"

class CrawlFlightsJob < ApplicationJob
  include FlightFormulas

  queue_as :default

  def perform(params)
    # flight_vja = SearchFlight::VietjetAir::Search.new(params).call
    # flights_jet = SearchFlight::Jetstar::Search.new(params).call
    # flights_vna = SearchFlight::VietnamAirlines::Search.new(params).call
    
    sleep 2 # For testing online

    data = {
      # depart_flights: flights_jet[:depart_flights] + flights_vna[:depart_flights] + flight_vja[:depart_flights],
      # return_flights: self.round_trip?(params[:round_type]) ? flights_jet[:return_flights] + flights_vna[:return_flights] + flight_vja[:return_flights] : nil
      itinerary: {
        category: params[:round_type],
        ori_airport: Airport.find_by(code: params[:ori_code]),
        des_airport: Airport.find_by(code: params[:des_code]),
        from_date: params[:depart_date],
        to_date: params[:return_date],
        adult_num: params[:adult],
        child_num: params[:child],
        infant_num: params[:infant]
      },
      depart_flights: [
        {
           airline_type: "jetstar",
           flight_code:"BL564",
           from_time:"9:20",
           to_time:"10:40",
           price_no_fee:810000,
           price_adult:1081000,
           price_child:1041000,
           price_infant:150000,
           price_total:1081000
        },
        {
           airline_type: "jetstar",
           flight_code:"BL560",
           from_time:"17:30",
           to_time:"18:50",
           price_no_fee:810000,
           price_adult:1081000,
           price_child:1041000,
           price_infant:150000,
           price_total:1081000
        },
        {
           airline_type: "vietnam_airlines",
           flight_code:"VN 160",
           from_time:"07:45",
           to_time:"09:05",
           price_no_fee:1400000,
           price_adult:1620000,
           price_child:1195000,
           price_infant:154000,
           price_total:1620000
        },
        {
           airline_type: "vietnam_airlines",
           flight_code:"VN 162",
           from_time:"08:10",
           to_time:"09:30",
           price_no_fee:2050000,
           price_adult:2335000,
           price_child:1731250,
           price_infant:225500,
           price_total:2335000
        },
        {
           airline_type: "vietjet_air",
           flight_code:"VJ516",
           from_time:"22:05",
           to_time:"23:20",
           price_no_fee:580000,
           price_adult:828000,
           price_child:788000,
           price_infant:0,
           price_total:828000
        },
        {
           airline_type: "vietjet_air",
           flight_code:"VJ528",
           from_time:"22:50",
           to_time:"00:05",
           price_no_fee:580000,
           price_adult:828000,
           price_child:788000,
           price_infant:0,
           price_total:828000
        }
      ],
      return_flights: self.round_trip?(params[:round_type]) ? [
        {
           airline_type: "jetstar",
           flight_code:"BL563",
           from_time:"9:35",
           to_time:"10:55",
           price_no_fee:420000,
           price_adult:652000,
           price_child:612000,
           price_infant:150000,
           price_total:652000
        },
        {
           airline_type: "jetstar",
           flight_code:"BL565",
           from_time:"15:25",
           to_time:"16:45",
           price_no_fee:370000,
           price_adult:597000,
           price_child:557000,
           price_infant:150000,
           price_total:597000
        },
        {
           airline_type: "vietnam_airlines",
           flight_code:"VN 7167",
           from_time:"09:55",
           to_time:"11:15",
           price_no_fee:2050000,
           price_adult:2335000,
           price_child:1731250,
           price_infant:225500,
           price_total:2335000
        },
        {
           airline_type: "vietnam_airlines",
           flight_code:"VN 7179",
           from_time:"10:20",
           to_time:"11:40",
           price_no_fee:2050000,
           price_adult:2335000,
           price_child:1731250,
           price_infant:225500,
           price_total:2335000
        },
        {
           airline_type: "vietjet_air",
           flight_code:"VJ515",
           from_time:"21:35",
           to_time:"22:50",
           price_no_fee:399000,
           price_adult:628900,
           price_child:588900,
           price_infant:0,
           price_total:628900
        },
        {
           airline_type: "vietjet_air",
           flight_code:"VJ535",
           from_time:"21:40",
           to_time:"22:55",
           price_no_fee:399000,
           price_adult:628900,
           price_child:588900,
           price_infant:0,
           price_total:628900
        }
        ] : []
    }

    ActionCable.server.broadcast("flights-#{params[:uuid]}", data: data)
  end
end
