class OrdersController < ApplicationController
  def new
    
  end

  def create
    byebug
  end

  def show
  end

  private
    def order_params
      params.require(:order).permit(:category, :from_date, :to_date, :contact_name, :contact_phone, :contact_email, :contact_gender, :adult, :child, :infant, :ori_airport_id, :des_airport_id, passengers_attributes: [:name, :gender, :category, :depart_lug_weight, :return_lug_weight, :dob])
    end
end
