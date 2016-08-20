class SearchHistory < ApplicationRecord
  belongs_to :route

  def self.trending
    search_history = where("created_at > ?", 30.days.ago)
    search_history.select("route_id, count(1) as number_top").group("route_id").order("number_top DESC").limit(6)
  end
end
