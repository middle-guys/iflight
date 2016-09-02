class MessengerBot
  include HTTParty
  base_uri "https://graph.facebook.com/v2.6/me"

  def call(params)
    if params["entry"][0]["messaging"].present? && params["entry"][0]["messaging"][0]["message"].present?
      messaging = params["entry"][0]["messaging"][0]
    end

    welcome_arr = ["hi", "hello"]
    search_arr = ["from", "to", "depart", "return"]

    if messaging
      message_received = messaging["message"]["text"]

      if match_content?(welcome_arr, message_received)
        send_message(messaging["sender"]["id"], "Hi, our please to help you A. Please note your itinerary (E.g, From SGN to DAD depart at 12/12/2016 and return at 15/12/2016)")
      elsif match_content?(search_arr, message_received)
        MessengerSearchFlightJob.perform_later(build_params(message_received.downcase, messaging["sender"]["id"]))
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
    response = self.class.post("/messages?access_token=#{ENV['PAGE_ACCESS_TOKEN']}", body: body, format: :json)
  end

  def match_content?(arr, str)
    arr.any? { |word| str.downcase.include?(word) }
  end

  def build_params(message, sender_id)
    index_from = message.index "from "
    index_to = message.index " to "
    index_depart = message.index " depart "
    index_return = message.index " return "

    params = {}
    params[:recipient_id] = sender_id
    params[:ori_code] = message[index_from + 4..index_to - 1].strip.upcase
    params[:des_code] = message[index_to + 3..index_depart].strip.upcase
    params[:adult] = 1
    params[:infant] = 0
    params[:child] = 0

    if index_return
      params[:round_type] = "RT"
      params[:date_depart] = message[index_depart..index_return]
      params[:date_return] = message[index_return..-1]
    else
      params[:round_type] = "OW"
      params[:date_depart] = message[index_depart..-1]
      params[:date_return] = nil
    end

    params
  end
end
