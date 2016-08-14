module BookFlight
  module Jetstar
    class RoundTrip < JetstarFormulas
      attr_accessor :agent_local, :params

      def initialize(agent_local, params)
        @agent_local = agent_local
        @params = params
      end

      def call
        search_page = search

        depart_flight_code_square = search_page.search(".depart tr").at("td.flight-code:contains('BL 788')")

        return 302 unless depart_flight_code_square

        depart_flight_price_selection = nil

        depart_flight_code_square.parent.search("td.selection").each do |price_selection|
          if price_selection.text.include? number_to_currency_jetstar 890000
            depart_flight_price_selection = price_selection
            break
          end
        end

        return 303 unless depart_flight_price_selection

        return_flight_code_square = search_page.search(".return tr").at("td.flight-code:contains('BL 799')")

        return 304 unless return_flight_code_square

        return_flight_price_selection = nil

        return_flight_code_square.parent.search("td.selection").each do |price_selection|
          if price_selection.text.include? number_to_currency_jetstar 890000
            return_flight_price_selection = price_selection
            break
          end
        end

        return 305 unless return_flight_price_selection
        byebug
        result = select_price_row(depart_flight_price_selection, return_flight_price_selection)

        File.open("out.html", "wb") do |f|
          f.write result.body
          f.close
        end

        # return 303 unless flight_price_selection

        # result = select_price_row(flight_price_selection)
      end

      def search
        agent_local.post(
          "https://agenthub.jetstar.com/TradeSalesHome.aspx",
          {
            "__EVENTTARGET" => "",
            "__EVENTARGUMENT" => "",
            "__VIEWSTATE" => "",
            "pageToken" => "",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$RadioButtonMarketStructure" => "RoundTrip",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketOrigin1" => "SGN",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketDestination1" => "HAN",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextboxDepartureDate1" => "16/08/2016",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextboxDepartureDate2" => "17/08/2016",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_ADT" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_CHD" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_INFANT" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_ADT" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_CHD" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_INFANT" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$numberTrips" => 2,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$ButtonSubmit" => ""
          }
        )
      end

      def select_price_row(depart_flight_price_selection, return_flight_price_selection)
        agent_local.post(
          "https://agenthub.jetstar.com/AgentSelect.aspx",
          {
            "__EVENTTARGET" => "ControlGroupAgentSelectView$ButtonSubmit",
            "__EVENTARGUMENT" => "",
            "__VIEWSTATE" => "",
            "pageToken" => "",
            "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$HiddenFieldTabIndex1" => 3,
            "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$HiddenFieldTabIndex2" => 4,
            "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$market1": depart_flight_price_selection.at("input")["value"],
            "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$market2" => return_flight_price_selection.at("input")["value"],
            "baggage-selection-toggler" => "on",
            "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0" => "BG15",
            "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0Pax0" => "BG15",
            "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0Pax1" => "BG15",
            "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney1" => "BG15",
            "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney1Pax0" => "BG15",
            "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney1Pax1" => "BG15",
            "marketstructure" => "RoundTrip"
          }
        )
      end
    end
  end
end
