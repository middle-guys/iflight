module BookFlight
  module Jetstar
    class Book < JetstarFormulas
      attr_accessor :agent

      def initialize
        @agent = agent_with_proxy
      end

      def call
        login

        round_trip?("RT") ? BookFlight::Jetstar::RoundTrip.new(agent, nil).call : BookFlight::Jetstar::OneWay.new(agent, nil).call
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
