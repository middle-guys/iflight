class HomesController < ApplicationController
  def index
    @ori_airports = Airport.where('id IN (?)', Route.all.select(:ori_airport_id)).order(:name_unsigned)
  end
end
