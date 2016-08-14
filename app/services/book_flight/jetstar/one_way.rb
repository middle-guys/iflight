module BookFlight
  module Jetstar
    class OneWay < JetstarFormulas
      attr_accessor :agent_local, :params

      def initialize(agent_local, params)
        @agent_local = agent_local
        @params = params
      end

      def call
        search_page = search

        flight_code_square = search_page.search(".depart tr").at("td.flight-code:contains('BL 790')")

        return 302 unless flight_code_square

        flight_price_selection = nil

        flight_code_square.parent.search("td.selection").each do |price_selection|
          if price_selection.text.include? format_currency 2020000
            flight_price_selection = price_selection
            break
          end
        end

        return 303 unless flight_price_selection

        result = select_price_row(flight_price_selection)

        File.open("out.html", "wb") do |f|
          f.write result.body
          f.close
        end
      end

      def search
        agent_local.post(
          "https://agenthub.jetstar.com/TradeSalesHome.aspx",
          {
            "__EVENTTARGET" => "",
            "__EVENTARGUMENT" => "",
            "__VIEWSTATE" => "",
            "pageToken" => "",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$RadioButtonMarketStructure" => "OneWay",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketOrigin1" => "SGN",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketDestination1" => "HAN",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextboxDepartureDate1" => "14/08/2016",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_ADT" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_CHD" => 0,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_INFANT" => 0,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_ADT" => 1,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_CHD" => 0,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_INFANT" => 0,
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$ButtonSubmit" => ""
          }
        )
      end

      def select_price_row(flight_price_selection)
        body = {
          "__EVENTTARGET" => "ControlGroupAgentSelectView$ButtonSubmit",
          "__EVENTARGUMENT" => "",
          "__VIEWSTATE" => "",
          "pageToken" => "",
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$HiddenFieldTabIndex1" => 2,
          "bannerFileName" => "",
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$market1" => flight_price_selection.at("input")["value"],
          "baggage-selection-toggler" => "on",
          "marketstructure" => "OneWay",
          "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0" => "BG15",
          "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0Pax0" => "none"
        }

        agent_local.post(
          "https://agenthub.jetstar.com/AgentSelect.aspx",
          body
        )
      end
    end
  end
end
