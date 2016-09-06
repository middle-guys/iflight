class SearchHistory < ApplicationRecord
  belongs_to :route

  def self.trending
    search_history = where("created_at > ?", 30.days.ago)
    search_history.select("route_id, count(1) as number_top").group("route_id").order("number_top DESC").limit(6)
  end

  def self.destination_trending
    routes = Route.joins(:search_histories)
    @airport_result_arr = Array.new
    airport_arr = routes.group(:des_airport_id).count.sort_by(&:last).reverse.slice(0, 6)
    airport_arr.each do |item|
      airport_element = Array.new
      airport_element.push(Airport.find(item[0])).push(item[1])
      @airport_result_arr.push(airport_element)
    end
    @airport_result_arr
  end
end
