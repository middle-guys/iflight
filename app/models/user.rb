class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :async
  validates_presence_of :gender
  validates_presence_of :name
  validates :phone,:numericality => true,
                 :length => { :minimum => 10, :maximum => 15 }
  has_many :orders
end
