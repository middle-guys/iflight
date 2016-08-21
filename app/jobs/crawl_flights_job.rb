require "flight_formulas"

class CrawlFlightsJob < ApplicationJob
  include FlightFormulas

  queue_as :default

  def perform(params)
    begin
      # flight_vja = SearchFlight::VietjetAir::Search.new(params).call
      # flights_jet = SearchFlight::Jetstar::Search.new(params).call
      # flights_vna = SearchFlight::VietnamAirlines::Search.new(params).call

      # data = {
      #   depart_flights: flights_jet[:depart_flights] + flights_vna[:depart_flights] + flight_vja[:depart_flights],
      #   return_flights: round_trip?(params[:round_type]) ? flights_jet[:return_flights] + flights_vna[:return_flights] + flight_vja[:return_flights] : nil,
      #   itinerary: {
      #     category: params[:round_type],
      #     ori_airport: Airport.find_by(code: params[:ori_code]),
      #     des_airport: Airport.find_by(code: params[:des_code]),
      #     date_depart: params[:date_depart],
      #     date_return: params[:date_return],
      #     adult_num: params[:adult],
      #     child_num: params[:child],
      #     infant_num: params[:infant]
      #   }
      # }

      sleep 4.5

      data = {
        itinerary: {
          category: params[:round_type],
          ori_airport: Airport.find_by(code: params[:ori_code]),
          des_airport: Airport.find_by(code: params[:des_code]),
          date_depart: params[:date_depart],
          date_return: params[:date_return],
          adult_num: params[:adult],
          child_num: params[:child],
          infant_num: params[:infant]
        },
        depart_flights: [
          {
              plane_category_id: 2,
             airline_type: "jetstar",
             code_flight:"BL564",
             time_depart:"9:20",
             time_arrive:"10:40",
             price_web:810000,
             price_adult:1081000,
             price_child:1041000,
             price_infant:150000,
             price_total:1081000
          },
          {
              plane_category_id: 2,
             airline_type: "jetstar",
             code_flight:"BL560",
             time_depart:"17:30",
             time_arrive:"18:50",
             price_web:810000,
             price_adult:1081000,
             price_child:1041000,
             price_infant:150000,
             price_total:1081000
          },
          {
              plane_category_id: 1,
             airline_type: "vietnam_airlines",
             code_flight:"VN 160",
             time_depart:"07:45",
             time_arrive:"09:05",
             price_web:1400000,
             price_adult:1620000,
             price_child:1195000,
             price_infant:154000,
             price_total:1620000
          },
          {
              plane_category_id: 1,
             airline_type: "vietnam_airlines",
             code_flight:"VN 162",
             time_depart:"08:10",
             time_arrive:"09:30",
             price_web:2050000,
             price_adult:2335000,
             price_child:1731250,
             price_infant:225500,
             price_total:2335000
          },
          {
              plane_category_id: 3,
             airline_type: "vietjet_air",
             code_flight:"VJ516",
             time_depart:"22:05",
             time_arrive:"23:20",
             price_web:580000,
             price_adult:828000,
             price_child:788000,
             price_infant:0,
             price_total:828000
          },
          {
              plane_category_id: 3,
             airline_type: "vietjet_air",
             code_flight:"VJ528",
             time_depart:"22:50",
             time_arrive:"00:05",
             price_web:580000,
             price_adult:828000,
             price_child:788000,
             price_infant:0,
             price_total:828000
          }
        ],
        return_flights: self.round_trip?(params[:round_type]) ? [
          {
              plane_category_id: 2,
             airline_type: "jetstar",
             code_flight:"BL563",
             time_depart:"9:35",
             time_arrive:"10:55",
             price_web:420000,
             price_adult:652000,
             price_child:612000,
             price_infant:150000,
             price_total:652000
          },
          {
              plane_category_id: 2,
             airline_type: "jetstar",
             code_flight:"BL565",
             time_depart:"15:25",
             time_arrive:"16:45",
             price_web:370000,
             price_adult:597000,
             price_child:557000,
             price_infant:150000,
             price_total:597000
          },
          {
              plane_category_id: 1,
             airline_type: "vietnam_airlines",
             code_flight:"VN 7167",
             time_depart:"09:55",
             time_arrive:"11:15",
             price_web:2050000,
             price_adult:2335000,
             price_child:1731250,
             price_infant:225500,
             price_total:2335000
          },
          {
              plane_category_id: 1,
             airline_type: "vietnam_airlines",
             code_flight:"VN 7179",
             time_depart:"10:20",
             time_arrive:"11:40",
             price_web:2050000,
             price_adult:2335000,
             price_child:1731250,
             price_infant:225500,
             price_total:2335000
          },
          {
              plane_category_id: 3,
             airline_type: "vietjet_air",
             code_flight:"VJ515",
             time_depart:"21:35",
             time_arrive:"22:50",
             price_web:399000,
             price_adult:628900,
             price_child:588900,
             price_infant:0,
             price_total:628900
          },
          {
              plane_category_id: 3,
             airline_type: "vietjet_air",
             code_flight:"VJ535",
             time_depart:"21:40",
             time_arrive:"22:55",
             price_web:399000,
             price_adult:628900,
             price_child:588900,
             price_infant:0,
             price_total:628900
          }
        ] : []
      }
    rescue Exception => e
      p e.message

      data = {
        error: 404
      }
    end

    create_search_history(params) unless data[:error]
    ActionCable.server.broadcast("flights-#{params[:uuid]}", data: data)
  end

  def create_search_history(params)
    ori_airport = Airport.find_by_code(params[:ori_code])
    des_airport = Airport.find_by_code(params[:des_code])
    route = Route.find_by(ori_airport: ori_airport, des_airport: des_airport)

    if route
      SearchHistory.create(route: route)
    end
  end
end