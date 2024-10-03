class CartSerializer
  include JSONAPI::Serializer

  attributes :id, :total_items, :total_price

  has_many :cart_items

  # Definir el total de productos en el carrito
  attribute :total_items do |cart|
    cart.cart_items.sum(:quantity)
  end

  # Definir el precio total del carrito
  attribute :total_price do |cart|
    cart.cart_items.joins(:product).sum('cart_items.quantity * products.price')
  end
end
