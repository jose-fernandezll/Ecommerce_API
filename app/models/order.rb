class Order < ApplicationRecord
  attr_accessor :card_token
  validates :status, presence: true
  validates :card_token, presence: true

  belongs_to :user
  after_commit :create_payment, on: :create

  has_one :payment
  has_many :order_items, dependent: :destroy

  enum status: { pending: 'pending', paid: 'paid', shipped: 'shipped' }
  enum payment_method: %i[credit_card]

  def create_payment
    params = {
      order_id: id,
      card_token: card_token,
      amount: total_price
    }
    Payment.create!(params)
  end

  def total_price
    order_items.sum { |item| item.quantity * item.price }
  end
end
