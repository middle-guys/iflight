if Rails.env.production?
  uri = URI.parse(ENV['REDISTOGO_URL'])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])
end

if REDIS.zcard "proxies" == 0
  list_proxies = ENV["PROXIES"].split(',')

  list_proxies.each do |proxy|
    REDIS.zadd("proxies", 0, proxy)
  end
end
