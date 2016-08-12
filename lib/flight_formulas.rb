module FlightFormulas
  def proxy
    REDIS.zrange("proxies", 0, -1).first
  end

  def update_proxy_count(proxy)
    REDIS.zincrby("proxies", 1, proxy)
  end

  def round_trip?(round_type)
    round_type == "RoundTrip"
  end

  def format_day(date)
    date.strftime("%d")
  end

  def format_date_jet(date)
    date.strftime("%d/%m/%Y")
  end

  def format_date_vna(date)
    date.strftime("%Y-%m-%d")
  end

  def format_month(date)
    date.strftime("%Y-%m")
  end
end
