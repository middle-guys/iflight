class MessengerBotController < ActionController::Base
  def message(event, sender)
    sender.reply({ text: "Reply: #{event['message']['text']}" })
  end

  def delivery(event, sender)
  end

  def postback(event, sender)
  end
end
