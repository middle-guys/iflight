class AlertsController < ApplicationController
	def index
		@alerts = Alert.all
	end

	def create
		@alert1 = Alert.new alert_params
		@alert1.status = "active"
		if @alert1.save and round_trip
			@success = true
			FlightMailer.alert_confirmation(@alert1).deliver_later
			respond_to do |f|
				f.js {render action: 'show', status: :created, location: @alert2}
			end
		else
			@success = false
		end
	end

	def unsubscribe
		@token = params["token"]
		@alert = Alert.find_by(token: @token)
		if @alert
			@alert.update(status: "inactive")
			flash[:notice] = t(:unsubscribe_success)
			redirect_to root_path
		else
			flash[:notice] = t(:unsubscribe_unsucsess)
		end
	end

	private
	def round_trip
		@trip_type = params["trip_type"]
		@success = true
		if @trip_type == "round_trip"
			@alert2 = Alert.new alert_params
			@alert2.ori_air_id = params["alert"]["des_air_id"]
			@alert2.des_air_id = params["alert"]["ori_air_id"]
			@alert2.time_start = params["todate"]
			@alert2.status = "active"
			if @alert2.save
				@success = true
			else
				@success = false
			end
		end
		return @success
	end
	def alert_params
		params.require(:alert).permit(:email, :name, :ori_air_id, :des_air_id, :time_start, :price_expect)
	end
end
