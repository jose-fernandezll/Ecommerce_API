class Order < ApplicationRecord
  attr_accessor :credit_card_number, :credit_card_exp_month, :credit_card_exp_year, :credit_card_cvv
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
      credit_card_number: credit_card_number,
      credit_card_exp_month: credit_card_exp_month,
      credit_card_exp_year: credit_card_exp_year,
      credit_card_cvv: credit_card_cvv
    }
    Payment.create!(params)
  end
end
