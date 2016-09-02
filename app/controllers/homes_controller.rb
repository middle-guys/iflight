class HomesController < ApplicationController
  protect_from_forgery except: [:webhook]

  def index
    @ori_airports = Airport.where('id IN (?)', Route.all.select(:ori_airport_id)).order(:name_unsigned)
    # @trending_search = SearchHistory.trending
    @destination_trending = SearchHistory.destination_trending
  end

  def webhook
    if request.get?
      if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == ENV["FB_VERIFY_TOKEN"]
        render json: params["hub.challenge"]
      end
    elsif request.post?
      # ap params
    end
  end
end
