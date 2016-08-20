module Sms
  class SmsSender
    def initialize(order)
      @order = order
      @receiver_phones = get_receiver_phones()
      @sms_content = Sms::SmsTemplateBinding.get_content(@order)
      @agent = Mechanize.new
      @agent.auth(ENV["SMS_USERNAME"], ENV["SMS_PASSWORD"])
      @sms_type = 2  # CSKH - can change later
      @headers = {
        "Content-Type" => "application/json"
      }
      @body = {
        "to"        => @receiver_phones,
        "content"   => @sms_content,
        "sms_tye"   => @sms_type,
        "brandname" => ""
      }
      @sms_service_url = "http://api.speedsms.vn/index.php/sms/send"
    end

    def send
      byebug
      response = @agent.post(@sms_service_url, @body.to_json, @headers)
    end

    private
      def get_receiver_phones
        [@order.contact_phone]
      end
  end
end