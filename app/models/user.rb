class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  enum role: {
    user: 0,
    admin: 1
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

end
