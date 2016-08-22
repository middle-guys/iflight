class Order < ApplicationRecord
  belongs_to :user
  belongs_to :des_airport, foreign_key: :des_airport_id, class_name: "Airport"
  belongs_to :ori_airport, foreign_key: :ori_airport_id, class_name: "Airport"
  has_many :flights, inverse_of: :order, dependent: :destroy
  has_many :passengers, inverse_of: :order, dependent: :destroy

  accepts_nested_attributes_for :passengers
  accepts_nested_attributes_for :flights

  enum status: {
    init: "init",
    reserving: "reserving",
    done: "done",
    failed: "failed",
    cancelled: "cancelled"
  }

  enum category: {
    one_way: "one_way",
    round_trip: "round_trip"
  }

  def self.generate_order_number
    loop do
      @order_number = SecureRandom.hex(16/4).upcase
      break unless Order.exists?(order_number: @order_number)
    end
    @order_number
  end

  def depart_flight
    flights.where(category: :depart).first
  end

  def return_flight
    flights.where(category: :return).first
  end
end
