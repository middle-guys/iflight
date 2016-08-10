module SearchFlight
  module VietnamAirline
    class Search
      include HTTParty
      base_uri "https://wl-prod.sabresonicweb.com"
      attr_accessor :params, :response

      def initialize(params)
        @params = params
      end

      def call
        @response = self.class.get build_path

        success? ? SearchFlight::VietnamAirline::Parse.new(
          content: response.body,
          is_round_trip: round_trip?,
          adult: params[:adult],
          child: params[:child],
          infant: params[:infant]
        ).call : []
      end

      def build_path
        path = String.new("/SSW2010/B3QE/webqtrip.html?searchType=NORMAL")

        path << "&journeySpan=" << get_round_type
        path << "&origin=" << params[:ori_code]
        path << "&destination=" << params[:des_code]
        path << "&departureDate=" << format_date(params[:depart_date])
        path << "&returnDate=" << format_date(params[:return_date]) if round_trip?
        path << "&numAdults=" << params[:adult].to_s
        path << "&numChildren=" << params[:child].to_s
        path << "&numInfants=" << params[:infant].to_s
        path << "&alternativeLandingPage=true&promoCode=&lang=vi_VN"

        path
      end

      def success?
        response.code == 200
      end

      def round_trip?
        params[:round_type] == "RoundTrip"
      end

      def get_round_type
        round_trip? ? "RT" : "OW"
      end

      def format_date(date)
        date.strftime("%Y-%m-%d")
      end
    end
  end
end
