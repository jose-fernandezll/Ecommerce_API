class OrderSerializer
  include JSONAPI::Serializer
  attributes :id, :created_at, :total_price

  has_many :order_items

  attribute :total_price do |order|
    order.total_price
  end
end
