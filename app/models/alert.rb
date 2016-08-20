class Alert < ApplicationRecord
	validates_presence_of :email
  	validates_presence_of :name
  	validates_presence_of :price_expect
  	has_secure_token
  	enum status:{
  		active: "active",
  		inactive: "inactive"
  	}
end
