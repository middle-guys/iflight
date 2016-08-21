module SearchFlight
  module VietjetAir
    class Search < VietjetAirFormulas
      attr_accessor :params, :response

      def initialize(params)
        @params = params
      end

      def call
        begin
          agent = agent_with_proxy

          first_response = agent.post "https://book.vietjetair.com/ameliapost.aspx?lang=vi", first_options, build_first_options[:headers]
          @response = agent.post "https://book.vietjetair.com/ameliapost.aspx?lang=vi", second_options, build_second_options(first_response)[:headers]

          update_proxy_count(agent.proxy_addr)

          success? ? SearchFlight::VietjetAir::Parse.new(
            content: response,
            is_round_trip: round_trip?(params[:round_type]),
            adult: params[:adult],
            child: params[:child],
            infant: params[:infant]
          ).call : []
        rescue Exception => e
          p e.message, "Vietjet Air Searching"
          nil
        end

      end

      def build_first_options
        {
          body: first_options,
          headers: {
            "Host" => "book.vietjetair.com",
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Referer" => "http://vietjetair.com/Sites/Web/vi-VN/Home"
          }
        }
      end

      def first_options
        {
          "txtPromoCode" => "",
          "lstDepDateRange" => "0",
          "lstRetDateRange" => "0",
          "lstLvlService" => "1",
          "blnFares" => "False",
          "lstCurrency" => "VND",
          "lstResCurrency" => "VND",
          "chkRoundTrip" => get_round_type,
          "txtNumInfants" => params[:infant],
          "txtNumChildren" => params[:child],
          "txtNumAdults" => params[:adult],
          "dlstDepDate_Day" => format_day(params[:date_depart]),
          "dlstRetDate_Day" => format_day(round_trip?(params[:round_type]) ? params[:date_return] : params[:date_depart]),
          "dlstRetDate_Month" => format_year_month(params[:date_depart]),
          "dlstDepDate_Month" => format_year_month(round_trip?(params[:round_type]) ? params[:date_return] : params[:date_depart]),
          "lstDestAP" => params[:des_code],
          "lstOrigAP" => params[:ori_code]
        }
      end

      def build_second_options(response)
        {
          body: second_options,
          headers: {
            "Cookie" => response.header["set-cookie"],
            "Accept-Encoding" => "gzip, deflate",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Referer" => "http://vietjetair.com/Sites/Web/vi-VN/Home"
          }
        }
      end

      def second_options
        {
          "__VIEWSTATE" => "/wEPDwULLTE1MzQ1MjI3MzAPZBYCZg9kFg4CCA8QZGQWAGQCCQ8QZGQWAGQCCw8QZGQWAGQCDQ8QZGQWAGQCEQ8QZGQWAGQCEg8QZGQWAGQCEw8QZGQWAGRk/SLp6eYBboDTdTTmIOra109LSis=",
          "txtPromoCode" => "",
          "lstDepDateRange" => "0",
          "lstRetDateRange" => "0",
          "lstLvlService" => "1",
          "lstCurrency" => "VND",
          "lstResCurrency" => "VND",
          "txtNumInfants" => "0",
          "txtNumChildren" => "0",
          "txtNumAdults" => "0",
          "lstOrigAP" => "-1",
          "lstDestAP" => "-1",
          "__VIEWSTATEGENERATOR" => "35449566",
          "SesID" => "",
          "DebugID" => round_trip?(params[:round_type]) ? "43" : "06",
          "dlstRetDate_Day" => format_day(Date.today),
          "dlstDepDate_Day" => format_day(Date.today),
          "dlstDepDate_Month" => format_year_month(Date.today),
          "dlstRetDate_Month" => format_year_month(Date.today)
        }
      end

      def success?
        response.code.to_i == 200
      end

      def get_round_type
        round_trip?(params[:round_type]) ? "on" : ""
      end
    end
  end
end
