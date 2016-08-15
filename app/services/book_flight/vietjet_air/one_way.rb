module BookFlight
  module VietjetAir
    class OneWay < VietjetAirFormulas
      attr_accessor :agent, :itinerary, :depart_flight, :passengers, :contact, :adult_passengers, :child_passengers, :infant_passengers

      def initialize(agent, params)
        @agent = agent
        @itinerary = params[:itinerary]
        @depart_flight = params[:depart_flight]
        @passengers = params[:passengers]
        @contact = params[:contact]
        @adult_passengers = passengers.select{ |x| x[:category] == 1 }
        @child_passengers = passengers.select{ |x| x[:category] == 2 }
        @infant_passengers = passengers.select{ |x| x[:category] == 3 }
      end

      def call
        select_price_page = search

        selected_price_element = get_selected_price_element(select_price_page, "toDepDiv", depart_flight[:flight_code], depart_flight[:price_no_fee])

        return 404 unless selected_price_element

        fill_info_page = select_price(selected_price_element)

        File.open("out.html", "wb") do |f|
          f.write fill_info_page.body
          f.close
        end

        # checkout_page = fill_info

        # reservation_page = checkout

        # {
        #   reservation_code: reservation_page.at("#booking-data booking")["pnr"],
        #   holding_date: reservation_page.at("#booking-data booking")["holddateutc"]
        # }
      end

      def search
        agent.post(
          "https://agent.vietjetair.com/ViewFlights.aspx?lang=vi&st=sl&sesid=",
          {
            "__VIEWSTATE" => "",
            "__VIEWSTATEGENERATOR" => "",
            "SesID" => "",
            "DebugID" => "10",
            "button" => "vfto",
            "dlstDepDate_Day" => format_day(itinerary[:depart_date]),
            "dlstDepDate_Month" => format_year_month(itinerary[:depart_date]),
            "dlstRetDate_Day" => format_day(itinerary[:depart_date]),
            "dlstRetDate_Month" => format_year_month(itinerary[:depart_date]),
            "lstDepDateRange" => "0",
            "lstRetDateRange" => "0",
            "chkRoundTrip" => "",
            "lstOrigAP" => itinerary[:ori_airport][:code],
            "lstDestAP" => itinerary[:des_airport][:code],
            "departure1" => format_date(itinerary[:depart_date]),
            "departTime1" => "0000",
            "departure2" => format_date(itinerary[:depart_date]),
            "departTime2" => "0000",
            "lstLvlService" => "1",
            "lstResCurrency" => "VND",
            "txtNumAdults" => itinerary[:adult_num],
            "txtNumChildren" => itinerary[:child_num],
            "txtNumInfants" => itinerary[:infant_num],
            "lstCompanyList" => "3184ƒCTY TNHH TM&DV DL BAO GIA TRAN (SUB 2)",
            "txtPONumber" => ""
          }
        )
      end

      def select_price(flight_price_selection)
        agent.post(
          "https://agent.vietjetair.com//TravelOptions.aspx?lang=vi&st=sl&sesid=",
          "__VIEWSTATE" => "",
          "__VIEWSTATEGENERATOR" => "",
          "button" => "continue",
          "SesID" => "",
          "DebugID" => "10",
          "PN" => "",
          "RPN" => "",
          "gridTravelOptDep" => travel_info(flight_price_selection),
          "gridTravelOptRet" => travel_info(flight_price_selection)
        )
      end

      def fill_info

      end

      def checkout

      end
    end
  end
end
