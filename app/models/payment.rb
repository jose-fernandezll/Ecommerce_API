class Payment < ApplicationRecord
  attr_accessor :card_token

  belongs_to :order
  before_validation :create_on_stripe

  def create_on_stripe
    params = { amount: order.amount_cents, currency: 'usd', source: card_token}
    response = Stripe::Charge.create(params)
    self.stripe_id = response.id
  end

end
