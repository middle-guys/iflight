class MessengerBot
  include HTTParty
  base_uri "https://graph.facebook.com/v2.6/me"
  attr_accessor :welcome_arr

  def call(params)
    if params["entry"][0]["messaging"].present? && params["entry"][0]["messaging"][0]["message"].present?
      messaging = params["entry"][0]["messaging"][0]
    end

    welcome_arr = ["hi", "hello", "xin chào", "chào"]

    if messaging
      message_received = messaging["message"]["text"]

      if match_content?(welcome_arr, message_received)
        send_message(messaging["sender"]["id"], "Hi, our please to help you A. Please note your itinerary (E.g, From SGN to DAD depart at 12/12/2016 and return at 15/12/2016)")
      else
        send_message(messaging["sender"]["id"], "Sorry, may I help you?")
      end
    end
  end

  def send_message(recipient_id, message_text)
    body = {
        recipient: {
          id: recipient_id
        },
        message: {
          text: message_text
        }
      }
    response = self.class.post("/messages?access_token=#{ENV['FB_VERIFY_TOKEN']}", body: body, format: :json)
  end

  def match_content?(arr, str)
    arr.any? { |word| str.downcase.include?(word) }
  end
end
