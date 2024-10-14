class OrdersController < ApplicationController
  before_action :set_cart, only: [:create]
  before_action :find_order, only: [:show, :update]

  def create
    authorize Order

    return render json: { error: 'Cart is empty' }, status: :unprocessable_entity if @cart.cart_items.empty?

    order = current_user.orders.build
    ActiveRecord::Base.transaction do

      @cart.cart_items.each do |cart_item|
        product = cart_item.product

        order.order_items.build(
          product: product,
          quantity: cart_item.quantity,
          price: product.price
        )

        product.update!(stock: product.stock - cart_item.quantity)
      end

      order.save!
      @cart.cart_items.destroy_all
    end

    render json: {
      message: "La orden ha sido creada exitosamente.",
      status: "pending",
      order: OrderSerializer.new(order).serializable_hash
    }, status: :created

  end

  def show
    authorize @order

    render json: OrderSerializer.new(@order, include: [:order_items]).serializable_hash.to_json
  end

  def update
    ActiveRecord::Base.transaction do
      update_order_items
      @order.save!
    end

    render json: OrderSerializer.new(@order, include: [:order_items]).serializable_hash.to_json, status: :ok
  end
  private

  def update_order_items
    order_params['order_items'].each do |item_params|
      product = Product.find(item_params[:product_id])
      order_item = @order.order_items.find_or_initialize_by(product: product)
      new_quantity = item_params[:quantity].to_i

      if new_quantity > 0 && new_quantity > product.stock
        raise InsufficientStockError.new(product)
      end

      if new_quantity <= 0
        order_item.destroy
      else

        stock_difference = new_quantity - (order_item.persisted? ? order_item.quantity : 0)
        product.update!(stock: product.stock - stock_difference)

        order_item.update!(quantity: new_quantity, price: product.price)
      end
    end
  end

  def set_cart
    @cart = current_user.cart
  end

  def find_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(order_items: [:product_id, :quantity])
  end
end
