class UrlShortener
  include HTTParty
  base_uri "https://www.googleapis.com/urlshortener/v1/"

  def call(long_url)
    response = self.class.post("/url?key=#{ENV['GOOGLE_API_KEY']}", body: { "longUrl" => long_url }.to_json, headers: { "Content-Type" => "application/json" })

    response["error"] ? nil : response["id"]
  end
end
