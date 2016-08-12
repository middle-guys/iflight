require "flight_formulas"

module SearchFlight
  module VietnamAirlines
    class Search
      include FlightFormulas
      attr_accessor :params, :response

      def initialize(params)
        @params = params
      end

      def call
        agent = self.agent

        @response = agent.get build_path

        self.update_proxy_count(agent.proxy_addr)

        success? ? SearchFlight::VietnamAirlines::Parse.new(
          content: response,
          is_round_trip: self.round_trip?(params[:round_type]),
          adult: params[:adult],
          child: params[:child],
          infant: params[:infant]
        ).call : []
      end

      def build_path
        path = String.new("https://wl-prod.sabresonicweb.com/SSW2010/B3QE/webqtrip.html?searchType=NORMAL")

        path << "&journeySpan=" << get_round_type
        path << "&origin=" << params[:ori_code]
        path << "&destination=" << params[:des_code]
        path << "&departureDate=" << self.format_date_vna(params[:depart_date])
        path << "&returnDate=" << self.format_date_vna(params[:return_date]) if self.round_trip?(params[:round_type])
        path << "&numAdults=" << params[:adult].to_s
        path << "&numChildren=" << params[:child].to_s
        path << "&numInfants=" << params[:infant].to_s
        path << "&alternativeLandingPage=true&promoCode=&lang=vi_VN"

        path
      end

      def success?
        response.code.to_i == 200
      end

      def get_round_type
        self.round_trip?(params[:round_type]) ? "RT" : "OW"
      end
    end
  end
end
