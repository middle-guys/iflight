module BookFlight
  module Jetstar
    class Book < JetstarFormulas
      attr_accessor :agent, :params

      def initialize(params)
        @agent = agent_with_proxy
        @params = params
      end

      def call
        begin
          login
        rescue Exeption => e
          p e.message, "Jetstar Login"
          return 403
        end

        round_trip?(params[:itinerary][:category]) ? BookFlight::Jetstar::RoundTrip.new(agent, params).call : BookFlight::Jetstar::OneWay.new(agent, params).call
      end

      def login
        agent.post(
          "https://agenthub.jetstar.com/newtradeloginagent.aspx",
          {
            "__EVENTTARGET" => "",
            "__EVENTARGUMENT" => "",
            "__VIEWSTATE" => "",
            "pageToken" => "",
            "ControlGroupNewTradeLoginAgentView$AgentNewTradeLoginView$ButtonLogIn" => "",
            "ControlGroupNewTradeLoginAgentView$AgentNewTradeLoginView$TextBoxUserID" => ENV["JETSTAR_USERNAME"],
            "ControlGroupNewTradeLoginAgentView$AgentNewTradeLoginView$PasswordFieldPassword" => ENV["JETSTAR_PASSWORD"],
          }
        )
      end
    end
  end
end
