class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_presence_of :gender
  validates_presence_of :name
  validates :phone,:numericality => true,
                 :length => { :minimum => 10, :maximum => 11 }
  has_many :orders, dependent: :destroy

end
