class SearchHistory < ApplicationRecord
  belongs_to :route

  def self.trending
    search_history = where("created_at > ?", 30.days.ago)
    # search_history.joins(:route).group(:route).order('count_all DESC').limit(6)
  end
end
