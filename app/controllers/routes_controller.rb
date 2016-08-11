class RoutesController < ApplicationController
  def destination
    routes = Route.all
    respond_to do |f|
      f.json { render json: routes.as_json(include: [:ori_airport, :des_airport]) }
    end
  end
end
