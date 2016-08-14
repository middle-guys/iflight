class FlightsController < ApplicationController
  def index
    @uuid = SecureRandom.uuid

    @ori_airport = Airport.find(params[:ori_airport_id])
    @des_airport = Airport.find(params[:des_airport_id])
    @from_date = params[:from_date]
    @to_date = params[:to_date]

    CrawlFlightsJob.perform_later(
      uuid: @uuid,
      ori_code: "SGN",
      des_code: "HAN",
      depart_date: "14/08/2016",
      adult: 2,
      child: 1,
      infant: 1,
      return_date: "15/08/2016",
      round_type: "RT"
    )
  end
end
