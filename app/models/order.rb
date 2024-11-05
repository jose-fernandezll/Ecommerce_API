class Order < ApplicationRecord
  attr_accessor :card_token
  validates :status, presence: true

  belongs_to :user
  after_create :create_payment

  has_one :payment
  has_many :order_items, dependent: :destroy

  enum status: { pending: 'pending', paid: 'paid', shipped: 'shipped' }
  enum payment_method: %i[credit_card]

  def create_payment
    params = {
      order_id: id,
      card_token: card_token
    }
    Payment.create!(params)
  end
end
