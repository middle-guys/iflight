require 'open-uri'
module BookFlight
  module VietnamAirlines
    class Book < VietnamAirlinesFormulas
      attr_accessor :agent, :params

      def initialize(params)
        @agent = agent_with_proxy
        @params = params
      end

      def call
        test = login

        File.open("out.html", "wb") do |f|
          f.write test.body
          f.close
        end
        # round_trip?(params[:itinerary][:category]) ? BookFlight::VietnamAirlines::RoundTrip.new(agent, params).call : BookFlight::VietnamAirlines::OneWay.new(agent, params).call
      end

      def login
        browser = Watir::Browser.new
        browser.goto "http://onlineairticket.vn/"
        session_id = browser.cookies["ASP.NET_SessionId"][:value]
        decode_text = browser.hidden(id: "CaptchaDeText").value
        browser.image(id: "CaptchaImage").screenshot("readme.png")
        browser.close

        client = TwoCaptcha.new(ENV["TWO_CAPTCHA_API_KEY"])
        captcha = client.decode!(raw64: Base64.encode64(File.open('readme.png', 'rb').read))

        ap captcha.text.upcase
        ap decode_text
        ap session_id

        agent.post(
          "http://onlineairticket.vn/",
          {
            "userName" => ENV["VIETNAM_AIRLINES_USERNAME"],
            "password" => ENV["VIETNAM_AIRLINES_PASSWORD"],
            "CaptchaDeText" => decode_text,
            "CaptchaInputText" => captcha.text.upcase,
            "x" => "0",
            "y" => "0"
          },
          {
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Accept-Encoding" => "gzip, deflate",
            "Origin" => "http://onlineairticket.vn",
            "Referer" => "http://onlineairticket.vn/",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Cookie" => "ASP.NET_SessionId=#{session_id}; CookieBookerInterface=BOOKER; TbsClientSite.CurrentUICulture=en-US"
          }
        )
      end
    end
  end
end
