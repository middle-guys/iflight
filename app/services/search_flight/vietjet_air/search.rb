module SearchFlight
  module VietjetAir
    class Search
      include HTTParty
      base_uri "http://book.vietjetair.com"
      attr_accessor :params, :response

      def initialize params
        @params = params
      end

      def call
        first_response = self.class.post "/ameliapost.aspx?lang=vi", build_first_options
        byebug
        @response = self.class.post "/ameliapost.aspx?lang=vi", build_second_options(first_response)
        byebug
      end

      def build_first_options
        {
          body: first_options,
          headers: {
            "Host": "book.vietjetair.com",
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/x-www-form-urlencoded"
          }
        }
      end

      def first_options
        {
          "txtPromoCode": "",
          "lstDepDateRange": "0",
          "lstRetDateRange": "0",
          "lstLvlService": "1",
          "blnFares": "False",
          "lstCurrency": "VND",
          "lstResCurrency": "VND",
          "chkRoundTrip": get_round_type,
          "txtNumInfants": params[:infant],
          "txtNumChildren": params[:child],
          "txtNumAdults": params[:adult],
          "dlstDepDate_Day": format_day(params[:depart_date]),
          "dlstRetDate_Day": format_day(round_trip? ? params[:return_date] : params[:depart_date]),
          "dlstRetDate_Month": format_month(params[:depart_date]),
          "dlstDepDate_Month": format_month(round_trip? ? params[:return_date] : params[:depart_date]),
          "lstDestAP": params[:des_code],
          "lstOrigAP": params[:ori_code]
        }
      end

      def build_second_options(response)
        options = {
          body: second_options,
          headers: {
            "Cookie": response.headers["set-cookie"],
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/x-www-form-urlencoded"
          }
        }
      end

      def second_options
        {
          "__VIEWSTATE": "/wEPDwULLTE1MzQ1MjI3MzAPZBYCZg9kFg4CCA8QZGQWAGQCCQ8QZGQWAGQCCw8QZGQWAGQCDQ8QZGQWAGQCEQ8QZGQWAGQCEg8QZGQWAGQCEw8QZGQWAGRk/SLp6eYBboDTdTTmIOra109LSis=",
          "txtPromoCode": "",
          "lstDepDateRange": "0",
          "lstRetDateRange": "0",
          "lstLvlService": "1",
          "lstCurrency": "VND",
          "lstResCurrency": "VND",
          "txtNumInfants": "0",
          "txtNumChildren": "0",
          "txtNumAdults": "0",
          "lstOrigAP": "-1",
          "lstDestAP": "-1",
          "__VIEWSTATEGENERATOR": "35449566",
          "SesID": "",
          "DebugID": round_trip? ? "43" : "06",
          "dlstRetDate_Day": format_day(Date.today),
          "dlstDepDate_Day": format_day(Date.today),
          "dlstDepDate_Month": format_month(Date.today),
          "dlstRetDate_Month": format_month(Date.today)
        }
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
