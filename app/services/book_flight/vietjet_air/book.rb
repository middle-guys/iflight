module BookFlight
  module VietjetAir
    class Book < VietjetAirFormulas
      attr_accessor :agent, :params

      def initialize(params)
        @agent = agent_with_proxy
        @params = params
      end

      def call
        login

        round_trip?(params[:itinerary][:category]) ? BookFlight::VietjetAir::RoundTrip.new(agent, params).call : BookFlight::VietjetAir::OneWay.new(agent, params).call
      end

      def login
        agent.get "https://agent.vietjetair.com/sitelogin.aspx?lang=vi"
        agent.post(
          "https://agent.vietjetair.com/sitelogin.aspx?lang=vi",
          {
            "__VIEWSTATE" => "",
            "__VIEWSTATEGENERATOR" => "",
            "SesID" => "",
            "DebugID" => "35",
            "txtAgentID" => ENV["VIETJET_AIR_USERNAME"],
            "txtAgentPswd" => ENV["VIETJET_AIR_PASSWORD"]
          }
        )
        agent.post(
          "https://agent.vietjetair.com/AgentOptions.aspx?lang=vi&st=sl&sesid=",
          "__VIEWSTATE" => "",
          "__VIEWSTATEGENERATOR" => "",
          "SesID" => "",
          "DebugID" => "10",
          "button" => "bookflight"
        )
      end
    end
  end
end
