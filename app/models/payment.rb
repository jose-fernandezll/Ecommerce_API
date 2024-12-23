class Payment < ApplicationRecord
  attr_accessor :card_token, :amount
  
  belongs_to :order
  after_create :create_on_stripe

  def create_on_stripe
    order = self.order
    params = { amount: order.total_price.to_i, currency: 'usd', source: card_token }

    response = Stripe::Charge.create(params)
    self.stripe_id = response.id
  end
end
