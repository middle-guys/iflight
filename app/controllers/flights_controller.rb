class FlightsController < ApplicationController
  def index
    @uuid = SecureRandom.uuid

    CrawlFlightsJob.perform_later(
      uuid: @uuid,
      ori_code: "SGN",
      des_code: "HAN",
      depart_date: "14/08/2016",
      adult: 1,
      child: 0,
      infant: 0,
      return_date: "15/08/2016",
      round_type: "OW"
    )
  end
end
