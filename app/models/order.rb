class Order < ApplicationRecord
  belongs_to :user
  belongs_to :des_airport, foreign_key: :des_airport_id, class_name: "Airport"
  belongs_to :ori_airport, foreign_key: :ori_airport_id, class_name: "Airport"
  has_many :flights
  has_many :passengers

  enum status: {
    reserving: "reserving",
    done: "done",
    failed: "failed",
    cancelled: "canceled"
  }

  enum category: {
    one_way: "one way",
    two_way: "two way"
  }
end
