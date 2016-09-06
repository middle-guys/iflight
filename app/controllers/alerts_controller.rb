class AlertsController < ApplicationController
	def index
		@alerts = Alert.all
	end

	def create
		@alert = Alert.new alert_params
		@alert.status = "active"
		if @alert.save
			@subscribe_successful = true
			FlightMailer.alert_confirmation(@alert).deliver_later
			respond_to do |f|
				f.js {render action: 'show', status: :created}
			end
		else
			@subscribe_successful = false
		end
	end

	def unsubscribe
		@token = params["token"]
		@alert = Alert.find_by(token: @token)
		if @alert
			@alert.update(status: "inactive")
			flash[:success] = "You have unsubscribe successfully"
			redirect_to root_path
		else
			flash[:notice] = "Something wrongs! Unsubscribe fails"
		end
	end

	private
		# def round_trip
		# 	@success = true
		# 	if round_trip?(params[:alert][:round_type])
		# 		@alert_return = Alert.new alert_params
		# 		@alert_return.ori_air_id = params["alert"]["des_air_id"]
		# 		@alert_return.des_air_id = params["alert"]["ori_air_id"]
		# 		@alert_return.time_start = params["todate"]
		# 		@alert_return.status = "active"
		# 		if @alert_return.save
		# 			@success = true
		# 		else
		# 			@success = false
		# 		end
		# 	end
		# 	return @success
		# end

		def alert_params
			params[:alert][:price_expect] = params[:alert][:price_expect].gsub(",", "")
			params.require(:alert).permit(:email, :name, :ori_air_id, :des_air_id, :price_expect, :time_start)
		end
end
