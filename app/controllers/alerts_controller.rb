class AlertsController < ApplicationController
	def index
		@alerts = Alert.all
	end

	def create
		@alert = Alert.new alert_params
		@alert.status = "active"
		if @alert.save
			@success = true
			respond_to do |f|
				f.js {render action: 'show', status: :created, location: @alert}
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
			flash[:notice] = "You have unsubscribe successfully"
			redirect_to root_path
		else
			flash[:notice] = "You have't unsubscribe successfully"
		end
	end

	private

	def alert_params
		params.require(:alert).permit(:email, :name, :ori_air_id, :des_air_id, :time_start, :price_expect)
	end
end
