class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum status: { pending: 'pending', paid: 'paid', shipped: 'shipped' }

  validates :status, presence: true
end
