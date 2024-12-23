class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  before_validation :create_on_stripe, on: :create
  has_one :cart, dependent: :destroy
  after_commit :create_cart, on: :create
  has_many :orders, dependent: :destroy

  validates :stripe_id, presence: true
  enum role: {
    user: 0,
    admin: 1
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self


  private

  def create_on_stripe
    response = Stripe::Customer.create({
      name: name,
      email: email
    })

    self.stripe_id = response.id
  end

  def create_cart
    Cart.create(user: self)
  end
end
