class CartsController < ApplicationController
  before_action :set_cart

  def add_item
    authorize @cart

    product = Product.find(params[:product_id])
    item = find_or_initialize_cart_item(product)

    render json: @cart, include: [:cart_items], status: :ok
  end

  def remove_item
    authorize @cart

    item = @cart.cart_items.find_by(product_id: params[:product_id])

    return render json: { error: "Item not found in cart" }, status: :not_found unless item

    item.destroy
    render json: @cart, include: [:cart_items], status: :ok
  end

  private

  def set_cart
    @cart = current_user.cart
  end

  def find_or_initialize_cart_item(product)
    item = @cart.cart_items.find_or_initialize_by(product: product)
    item.quantity += params[:quantity].to_i
    item.save
    item
  end
end
