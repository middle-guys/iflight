module SearchFlight
  module VietjetAir
    class Search
      attr_accessor :params, :response

      def initialize params
        @params = params
      end

      def call
        agent = Mechanize.new
        first_response = agent.post "https://book.vietjetair.com/ameliapost.aspx?lang=vi", first_options, build_first_options[:headers]
        @response = agent.post "https://book.vietjetair.com/ameliapost.aspx?lang=vi", second_options, build_second_options(first_response)[:headers]

        success? ? SearchFlight::VietjetAir::Parse.new(
          content: response,
          is_round_trip: round_trip?,
          adult: params[:adult],
          child: params[:child],
          infant: params[:infant]
        ).call : []
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
          "dlstDepDate_Day" => format_day(params[:depart_date]),
          "dlstRetDate_Day" => format_day(round_trip? ? params[:return_date] : params[:depart_date]),
          "dlstRetDate_Month" => format_month(params[:depart_date]),
          "dlstDepDate_Month" => format_month(round_trip? ? params[:return_date] : params[:depart_date]),
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
          "DebugID" => round_trip? ? "43" : "06",
          "dlstRetDate_Day" => format_day(Date.today),
          "dlstDepDate_Day" => format_day(Date.today),
          "dlstDepDate_Month" => format_month(Date.today),
          "dlstRetDate_Month" => format_month(Date.today)
        }
      end

      def success?
        response.code.to_i == 200
      end

      def round_trip?
        params[:round_type] == "RoundTrip"
      end

      def get_round_type
        round_trip? ? "on" : ""
      end

      def format_day(date)
        date.strftime("%d")
      end

      def format_month(date)
        date.strftime("%Y-%m")
      end
    end
  end
end
