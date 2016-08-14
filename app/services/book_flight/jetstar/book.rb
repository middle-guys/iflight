module BookFlight
  module Jetstar
    class Book < JetstarFormulas
      attr_accessor :agent_local

      def initialize
        @agent_local = self.agent
      end

      def call
        login

        round_trip?("RT") ? BookFlight::Jetstar::RoundTrip.new(agent_local, nil).call : BookFlight::Jetstar::OneWay.new(agent_local, nil).call
      end

      def login
        agent_local.post(
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
