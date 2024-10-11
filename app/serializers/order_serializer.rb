class OrderSerializer
  include JSONAPI::Serializer
  attributes :id, :created_at, :total_price

  has_many :order_items

  attribute :total_price do |order|
    order.order_items.sum { |item| item.quantity * item.price }
  end
end
