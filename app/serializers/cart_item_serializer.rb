class CartItemSerializer
  include JSONAPI::Serializer

  attributes :id, :quantity

  belongs_to :product
end
