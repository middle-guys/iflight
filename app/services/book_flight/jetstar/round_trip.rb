module BookFlight
  module Jetstar
    class RoundTrip < JetstarFormulas
      attr_accessor :agent, :itinerary, :depart_flight, :return_flight, :passengers

      def initialize(agent, params)
        @agent = agent
        @itinerary = params[:itinerary]
        @depart_flight = params[:depart_flight]
        @return_flight = params[:return_flight]
        @passengers = params[:passengers]
      end

      def call
        search_page = search

        File.open("out.html", "wb") do |f|
          f.write search_page.body
          f.close
        end

        depart_selected_price_element = get_selected_price_element(search_page, "depart", depart_flight[:flight_code], depart_flight[:price_no_fee])

        return 404 unless depart_selected_price_element

        return_selected_price_element = get_selected_price_element(search_page, "return", return_flight[:flight_code], return_flight[:price_no_fee])

        return 404 unless return_selected_price_element

        fill_info_page = select_price(depart_selected_price_element, return_selected_price_element)

        File.open("out.html", "wb") do |f|
          f.write fill_info_page.body
          f.close
        end
      end

      def search
        agent.post(
          "https://agenthub.jetstar.com/TradeSalesHome.aspx",
          {
            "__EVENTTARGET" => "",
            "__EVENTARGUMENT" => "",
            "__VIEWSTATE" => "",
            "pageToken" => "",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$RadioButtonMarketStructure" => "RoundTrip",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketOrigin1" => itinerary[:ori_airport][:code],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketDestination1" => itinerary[:des_airport][:code],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextboxDepartureDate1" => format_date(itinerary[:depart_date]),
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextboxDepartureDate2" => format_date(itinerary[:return_date]),
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_ADT" => itinerary[:adult_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_CHD" => itinerary[:child_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_INFANT" => itinerary[:infant_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_ADT" => itinerary[:adult_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_CHD" => itinerary[:child_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_INFANT" => itinerary[:infant_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$numberTrips" => 2,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$ButtonSubmit" => ""
          }
        )
      end

      def select_price(depart_flight_price_selection, return_flight_price_selection)
        body = {
          "__EVENTTARGET" => "ControlGroupAgentSelectView$ButtonSubmit",
          "__EVENTARGUMENT" => "",
          "__VIEWSTATE" => "",
          "pageToken" => "",
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$HiddenFieldTabIndex1" => 3,
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$HiddenFieldTabIndex2" => 4,
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$market1" => depart_flight_price_selection.at("input")["value"],
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$market2" => return_flight_price_selection.at("input")["value"],
          "baggage-selection-toggler" => "on",
          "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0" => "BG15",
          "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney1" => "BG15",
          "marketstructure" => "RoundTrip"
        }

        (itinerary[:adult_num] + itinerary[:child_num]).times do |index|
          body["AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0Pax#{index}"] = get_luggage(passengers[index][:luggage_depart])
          body["AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney1Pax#{index}"] = get_luggage(passengers[index][:luggage_return])
        end

        agent.post(
          "https://agenthub.jetstar.com/AgentSelect.aspx",
          body
        )
      end

      def book

      end
    end
  end
end
