class InsufficientStockError < StandardError
  def initialize(product)
    super("Insufficient stock for product #{product.name}")
  end
end
