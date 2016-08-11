require "mechanize"

module SearchFlight
  module Jetstar
    class Search
      attr_accessor :params, :response

      def initialize(params)
        @params = params
      end

      def call
        agent = Mechanize.new
        search_result = nil

        agent.get("https://booknow.jetstar.com/Search.aspx?culture=vi-VN") do |page|
          search_result = page.form_with(id: "SkySales") do |form|
            round_trip? ? two_way_options(form) : one_way_options(form)
          end.submit

          File.open("out.html", "wb") do |f|
            f.write search_result.body
          end
          byebug
        end

        SearchFlight::Jetstar::Parse.new(
          content: search_result,
          is_round_trip: round_trip?,
          adult: params[:adult],
          child: params[:child],
          infant: params[:infant]
        ).call
      end

      def one_way_options(form)
        form["search-origin01"] = ""
        form["search-destination01"] = ""
        form["ControlGroupSearchView$ButtonSubmit"] = ""
        form["__VIEWSTATE"] = ""
        form["infants"] = params[:infant]
        form["children"] = params[:child]
        form["adults"] = params[:adult]
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_INFANT"] = params[:infant]
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_CHD"] = params[:child]
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_ADT"] = params[:adult]
        form["datedepart-01"] = format_date(params[:depart_date])
        form["datereturn-01"] = ""
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketMonth1"] = format_month(params[:depart_date])
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDay1"] = format_day(params[:depart_date])
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketOrigin1"] = params[:ori_code]
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketDestination1"] = params[:des_code]
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListFareTypes"] = "I"
        form["travel-indicator"] = "on"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$RadioButtonMarketStructure"] = get_round_type
        form["pageToken"] = "sLkmnwXwAsY="
        form["culture"] = "vi-VN"
        form["currencyPicker"] = "VND"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListCurrency"] = "VND"
      end

      def two_way_options(form)
        form["search-origin01"] = ""
        form["search-destination01"] = ""
        form["ControlGroupSearchView$ButtonSubmit"] = ""
        form["__VIEWSTATE"] = ""
        form["infants"] = 0
        form["children"] = 0
        form["adults"] = 1
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_INFANT"] = 0
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_CHD"] = 0
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListPassengerType_ADT"] = 1
        form["datedepart-01"] = "12/08/2016"
        form["datereturn-01"] = "13/08/2016"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketMonth1"] = "2016-08"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDay1"] = "12"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketOrigin1"] = "SGN"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$TextBoxMarketDestination1"] = "HAN"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListFareTypes"] = "I"
        form["travel-indicator"] = "on"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$RadioButtonMarketStructure"] = "RoundTrip"
        form["pageToken"] = "sLkmnwXwAsY="
        form["culture"] = "vi-VN"
        form["locale"] = "vi-VN"
        form["currencyPicker"] = "VND"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListCurrency"] = "VND"
        form["undefined"] = "null"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDay2"] = "13"
        form["ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketMonth2"] = "2016-08"
        form["_pe_39b5379c652b_9df496572198"] = "null"
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
