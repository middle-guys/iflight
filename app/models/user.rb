class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_presence_of :gender
  validates_presence_of :name
  has_many :orders, dependent: :destroy

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    if user
      return user
    else
      registered_user = User.where(email: auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name: auth.extra.raw_info.name, gender: auth.extra.raw_info.gender, image: auth.info.image, 
                           provider: auth.provider, uid: auth.uid, email: auth.info.email, password: Devise.friendly_token[0, 20])
      end
    end
  end

  def image_avatar
    if image
      return image
    else
      return "https://api.adorable.io/avatars/100/#{email}"
    end
  end
end
