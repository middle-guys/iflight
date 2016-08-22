module Sms
  class SmsTest
    def self.show
      file = File.join(Rails.root, 'app', 'helper', 'sms', 'template.txt')
      order_number = "12345"
      data = File.read(file)
      data.gsub("\\#", "#")
      data
    end

    def self.check_account
      agent = Mechanize.new
      agent.auth(ENV["SMS_USERNAME"], ENV["SMS_PASSWORD"])
      response = agent.get("http://api.speedsms.vn/index.php/user/info")
      response
    end

    def self.send_sms
      headers = {
        "Content-Type" => "application/json"
      }
      body = {
        "to"        => ["0933554440"],
        "content"   => "Do you want to book the cheapest flight ticket right now ? Call us - Middle Guys - Ahihihi!",
        "sms_tye"   => "2",
        "brandname" => ""
      }
      agent = Mechanize.new
      agent.auth(ENV["SMS_USERNAME"], ENV["SMS_PASSWORD"])
      response = agent.post('http://api.speedsms.vn/index.php/sms/send', body.to_json, headers)
    end
  end
end