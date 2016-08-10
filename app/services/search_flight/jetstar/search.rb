require 'mechanize'

module SearchFlight
  module Jetstar
    class Search
      include HTTParty
      base_uri "http://booknow.jetstar.com"

      attr_accessor :params, :response

      def initialize(params)
        @params = params
      end

      def call
        @response = self.class.post "/Search.aspx?culture=vi-VN", build_options

        success? ? SearchFlight::Jetstar::Parse.new(
          content: response.body,
          is_round_trip: round_trip?,
          adult: params[:adult],
          child: params[:child],
          infant: params[:infant]
        ).call : []
      end

      def build_options
        {
          body: round_trip? ? two_way_options : one_way_options,
          headers: {
            "Accept-Encoding": "gzip, deflate",
            "Content-type": "application/x-www-form-urlencoded"
          }
        }
      end

      def one_way_options
        {
          "search-origin01": "",
          "search-destination01": "",
          "ControlGroupSearchView$ButtonSubmit": "",
          "__VIEWSTATE": "",
          "infants": params[:infant],
          "children": params[:child],
          "adults": params[:adult],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_INFANT": params[:infant],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_CHD": params[:child],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_ADT": params[:adult],
          "datedepart-01": format_date(params[:depart_date]),
          "datereturn-01": "",
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketMonth1": format_month(params[:depart_date]),
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDay1": format_day(params[:depart_date]),
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketOrigin1": params[:ori_code],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketDestination1": params[:des_code],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListFareTypes": "I",
          "travel-indicator": "on",
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$RadioButtonMarketStructure": get_round_type,
          "pageToken": "sLkmnwXwAsY=",
          "culture": "vi-VN",
          "currencyPicker": "VND",
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListCurrency": "VND"
        }
      end

      def two_way_options
        {
          "search-origin01": "",
          "search-destination01": "",
          "ControlGroupSearchView$ButtonSubmit": "",
          "__VIEWSTATE": "",
          "undefined": "",
          "infants": params[:infant],
          "children": params[:child],
          "adults": params[:adult],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_INFANT": params[:infant],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_CHD": params[:child],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_ADT": params[:adult],
          "datedepart-01": format_date(params[:depart_date]),
          "datereturn-01": format_date(params[:return_date]),
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDay1": format_day(params[:depart_date]),
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketMonth1": format_month(params[:depart_date]),
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDay2": format_day(params[:return_date]),
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketMonth2": format_month(params[:return_date]),
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketOrigin1": params[:ori_code],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketDestination1": params[:des_code],
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListFareTypes": "I",
          "_pe_39b5379c652b_9df496572198": "null",
          "travel-indicator": "on",
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$RadioButtonMarketStructure": get_round_type,
          "pageToken": "sLkmnwXwAsY=",
          "culture": "vi-VN",
          "locale": "vi-VN",
          "currencyPicker": "VND",
          "ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListCurrency": "VND"
        }
      end

      def success?
        response.code == 200
      end

      def get_round_type
        round_trip? ? "RoundTrip" : "OneWay"
      end

      def round_trip?
        @params[:round_type] == "RoundTrip"
      end

      def format_day(date)
        date.strftime("%d")
      end

      def format_date(date)
        date.strftime("%d/%m/%Y")
      end

      def format_month(date)
        date.strftime("%Y-%m")
      end
    end
  end
end
