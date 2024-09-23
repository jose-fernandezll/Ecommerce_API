class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_one :cart, dependent: :destroy
  after_commit :create_cart, on: :create

  enum role: {
    user: 0,
    admin: 1
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  private

  def create_cart
    Cart.create(user: self)
  end
end
